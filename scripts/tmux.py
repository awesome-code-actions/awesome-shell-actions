#!/usr/bin/env python3.12
from dataclasses import dataclass
import json
import sys
import invoke


from dataclasses import dataclass, field, fields
from dataclasses_json import dataclass_json, DataClassJsonMixin
from typing import ClassVar


@dataclass
class Pane(DataClassJsonMixin):
    delimeter: ClassVar[str] = "\t"
    session_name: str = field(default="", metadata={"fmt": "#{session_name}"})
    window_index: int = field(default=0, metadata={"fmt": "#{window_index}"})
    window_active: bool = field(default=False, metadata={
                                "fmt": "#{window_active}"})
    window_flags: str = field(default="", metadata={"fmt": ":#{window_flags}"})
    pane_index: int = field(default=0, metadata={"fmt": "#{pane_index}"})

    mytitle: str = field(default="", metadata={"fmt": "#{@mytitle}"})
    pane_active: bool = field(default=False, metadata={
                              "fmt": "#{pane_active}"})
    pane_current_path: str = field(
        default="", metadata={"fmt": "#{pane_current_path}"})
    pane_pid: int = field(default=0, metadata={"fmt": "#{pane_pid}"})
    history_size: int = field(default=0, metadata={"fmt": "#{history_size}"})

    @classmethod
    def to_tmux_fmt(cls) -> str:
        format_parts = ["pane"]
        for field in fields(cls):
            format_parts.append(field.metadata["fmt"])
        return cls.delimeter.join(format_parts)

    @classmethod
    def from_line(cls, line: str):
        vals = [x.strip() for x in line.split(cls.delimeter)[1:]]
        obj = {}
        for index, f in enumerate(fields(cls)):
            obj[f.name] = vals[index]
        return cls(
            session_name=obj["session_name"],
            window_index=int(obj["window_index"]),
            window_active=bool(obj["window_active"]),
            window_flags=obj["window_flags"],
            pane_index=int(obj["pane_index"]),
            mytitle=obj["mytitle"],
            pane_active=bool(obj["pane_active"]),
            pane_current_path=obj["pane_current_path"],
            pane_pid=int(obj["pane_pid"]),
            history_size=int(obj["history_size"])
        )


class TmuxCli:
    def __init__(self):
        self.run = invoke.run

    def list_pane(self) -> list[Pane]:
        panes = self.run(
            f"tmux list-panes -a -F \"{Pane.to_tmux_fmt()}\"", hide=True).stdout
        return [Pane.from_line(x) for x in panes.splitlines()]


class X:
    def list_panel(self):
        cli = TmuxCli()
        ps = cli.list_pane()
        print(Pane.schema().dumps(ps, many=True))
    pass


if __name__ == "__main__":
    cmd = sys.argv[1]

    cmd = cmd.replace("-", "_").removeprefix("tmux_")
    X().__getattribute__(cmd)(*sys.argv[2:])
