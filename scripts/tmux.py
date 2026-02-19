# /// script
# dependencies = [
#   "dataclasses",
#   "dataclasses-json",
#   "invoke",
# ]
# ///
from dataclasses import dataclass
import os
import sys
from time import sleep
import invoke


from dataclasses import dataclass, field, fields
from dataclasses_json import dataclass_json, DataClassJsonMixin
from pathlib import Path
from typing import ClassVar

@dataclass
class Window(DataClassJsonMixin):
    delimeter: ClassVar[str] = "\t"
    session_name: str = field(default="", metadata={"fmt": "#{session_name}"})
    window_index: int = field(default=0, metadata={"fmt": "#{window_index}"})
    window_name: str = field(default="", metadata={
                             "fmt": ":#{window_name}"})
    window_active: bool = field(default=False, metadata={
                                "fmt": "#{window_active}"})
    window_flags: str = field(default="", metadata={"fmt": ":#{window_flags}"})
    window_layout: str = field(default="", metadata={
                               "fmt": "#{window_layout}"})

    @classmethod
    def to_tmux_fmt(cls) -> str:
        format_parts = ["window"]
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
            window_name=obj["window_name"],
            window_active=bool(obj["window_active"] == "1"),
            window_flags=obj["window_flags"],
            window_layout=obj["window_layout"]
        )


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
    mybooter: str = field(default="", metadata={"fmt": "#{@mybooter}"})
    mypreboot: str = field(default="", metadata={"fmt": "#{@mypreboot}"})
    pane_active: bool = field(default=False, metadata={
                              "fmt": "#{pane_active}"})
    pane_current_path: str = field(
        default="", metadata={"fmt": "#{pane_current_path}"})

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
            window_active=obj["window_active"] == "1",
            window_flags=obj["window_flags"],
            pane_index=int(obj["pane_index"]),
            mytitle=obj["mytitle"],
            mybooter=obj["mybooter"],
            mypreboot=obj["mypreboot"],
            pane_active=obj["pane_active"] == "1",
            pane_current_path=obj["pane_current_path"],
        )


class TmuxCli:
    def __init__(self):
        pass
    def lrun(self, cmd: str, **kwargs):
        print(cmd)
        if os.environ.get("TMUX_DRY_RUN", "") == "true":
            return
        return invoke.run(cmd, **kwargs)
    def run(self, cmd: str, **kwargs):
        return invoke.run(cmd, **kwargs)

    def ami_intmux(self) -> bool:
        return os.environ.get("TMUX", "") != ""

    def list_options(self, session_name: str) -> dict[str, str]:
        opts = self.run(
            f"tmux show-options  -t {session_name}", hide=True).stdout
        return {x.split()[0]: x.split()[1] for x in opts.splitlines() if x.startswith("@my_")}

    def list_pane(self, session_name: str) -> list[Pane]:
        panes = self.run(
            f"tmux list-panes -t {session_name} -F \"{Pane.to_tmux_fmt()}\"", hide=True).stdout
        ps = [Pane.from_line(x) for x in panes.splitlines()]
        ps.sort(key=lambda x: x.window_index*100+x.pane_index)
        return ps

    def cur_session(self) -> str:
        return self.run("tmux display-message -p '#S'", hide=True).stdout.strip()

    def list_window(self, session_name: str) -> list[Pane]:
        panes = self.run(
            f"tmux list-windows -t {session_name} -F \"{Window.to_tmux_fmt()}\"", hide=True).stdout
        ws = [Window.from_line(x) for x in panes.splitlines()]
        sorted(ws, key=lambda x: x.window_index)
        return ws


@dataclass
class Layout(DataClassJsonMixin):
    session_name: str
    wins: list[Window]
    panes: list[Pane]
    var: dict[str, str] = field(default_factory=dict)


class X:
    def __init__(self):
        self.cli = TmuxCli()

    def list_panel(self, name: str):
        ps = self.cli.list_pane(name)
        print(Pane.schema().dumps(ps, many=True))

    def list_window(self, name: str):
        ps = self.cli.list_window(name)
        print(Window.schema().dumps(ps, many=True))

    def _fetch_var_path(self, layout: Layout):
        env = {}
        my_var_path = layout.var.get("@my_var_path", None)
        if my_var_path is None:
            return None
        for e in my_var_path.split(","):
            env[e] = os.environ.get(e, "")
        return env

    def _resolve_var_path(self, layout: Layout):
        env = self._fetch_var_path(layout)
        if env is None:
            return
        for p in layout.panes:
            pcp = p.pane_current_path
            for k, v in env.items():
                if pcp.startswith("$"+k):
                    p.pane_current_path = pcp.replace("$"+k, v)
        pass

    def _patch_var_path(self, layout: Layout):
        env = self._fetch_var_path(layout)
        if env is None:
            return
        for p in layout.panes:
            pcp = p.pane_current_path
            for k, v in env.items():
                if pcp.startswith(v):
                    p.pane_current_path = pcp.replace(v, "$"+k)
        pass

    def save(self, output: str):
        session_name = self.cli.cur_session()
        var = self.cli.list_options(session_name)
        layout = Layout(session_name=session_name, wins=self.cli.list_window(
            session_name), panes=self.cli.list_pane(session_name), var=var)
        self._patch_var_path(layout)
        data=layout.to_json(indent=2, ensure_ascii=False)
        if output == "-":
            print(data)
            return
        pass
        p = f"{output}/{layout.session_name}.tmux.json"
        Path(p).write_text(data)
        print(p)
        pass

    def gen_tmux_send_keys(self, booter: str,without_enter:bool=False):
        if not booter:
            raise ValueError("booter is empty")

        delimeter = booter[0]
        print(f"|{booter}|   |{delimeter}|")
        cmds=[]
        if delimeter != "@":
            cmds=[booter]
            pass
        else:
            cmds = [f"'{x.strip()}'" for x in booter.removeprefix(
            delimeter).split(delimeter)]
        print(f"cmds is {cmds}")
        cmds.insert(0, "C-c")
        full = " 'enter' ".join(cmds)
        if without_enter:
            return f"{full};"
        return f"{full} 'enter';"

    def load(self, fpath: str):
        exp = Layout.from_json(Path(fpath).read_text())
        if not self.cli.ami_intmux():
            raise Exception("在tmux环境下执行")
        session_name = self.cli.cur_session()
        cur = Layout(session_name=self.cli.cur_session(), wins=self.cli.list_window(session_name),
                     panes=self.cli.list_pane(session_name))

        for k, v in exp.var.items():
            self.cli.lrun(
                f"tmux set-option -t {session_name} {k} {v}", hide=True)
        self._resolve_var_path(exp)
        for w in exp.wins:
            cur_win_index = [x.window_index for x in cur.wins]
            if w.window_index not in cur_win_index:
                self.cli.lrun(
                    f"tmux new-window -d -t \"{session_name}:{w.window_index}\"", hide=True)
            self.cli.lrun(
                f"tmux rename-window -t \"{session_name}:{w.window_index}\"  \"{w.window_name}\"", hide=True)
        # 创建panel
        for p in exp.panes:
            cur_pane_index = [x.pane_index for x in cur.panes]
            if p.pane_index not in cur_pane_index:
                self.cli.lrun(
                    f"tmux split-window -t \"{session_name}:{p.window_index}\" -c \"{p.pane_current_path}\"", hide=True)
                self.cli.lrun(
                    f"tmux select-layout -t \"{session_name}:{p.window_index}\" tiled", hide=True)
        # 设置layout
        for w in exp.wins:
            self.cli.lrun(
                f"tmux select-layout -t \"{session_name}:{w.window_index}\" \"{w.window_layout}\"", hide=True)
        # 设置option
        for p in exp.panes:
            t = f"{session_name}:{p.window_index}.{p.pane_index}"

            cmd = f"""tmux set-option -p -t "{t}" @mytitle "{p.mytitle}" """
            self.cli.lrun(cmd, hide=True)

            cmd = f"""tmux set-option -p -t "{t}" @mypreboot "{p.mypreboot}" """
            self.cli.lrun(cmd, hide=True)

            cmd = f"""tmux set-option -p -t "{t}" @mybooter "{p.mybooter}" """
            self.cli.lrun(cmd, hide=True)
        sleep(5)
        # prebooter
        print("preboot")
        for p in exp.panes:
            print(f"preboot title: {p.mytitle} index: {p.pane_index}")
            t = f"{session_name}:{p.window_index}.{p.pane_index}"
            if p.mypreboot is None or p.mypreboot.strip() == "":
                continue
            cmd = self.gen_tmux_send_keys(p.mypreboot)
            print(f"do preboot |{p.mypreboot}| cmd is {cmd}")
            if p.pane_active:
                cmd=cmd.removesuffix("'enter'")
            self.cli.lrun(f""" tmux send-keys -t {t} {cmd} """, hide=True)
        print("booter")
        sleep(3)
        for p in exp.panes:
            t = f"{session_name}:{p.window_index}.{p.pane_index}"
            if p.mybooter is None or p.mybooter.strip() == "":
                continue
            cmd = self.gen_tmux_send_keys(p.mybooter,without_enter=p.pane_active)
            self.cli.lrun(f""" tmux send-keys -t "{t}" {cmd} """, hide=True)
        pass

        # focus window and pane
        for p in exp.panes:
            if p.pane_active:
                t = f"{session_name}:{p.window_index}.{p.pane_index}"
            self.cli.lrun(
                f"""tmux switch-client -t "{session_name}:{p.window_index}" """, hide=True)
            self.cli.lrun(
                f"""tmux select-pane -t "{p.pane_index}" """, hide=True)
        for w in exp.wins:
            if w.window_active:
                self.cli.lrun(
                    f"""tmux select-window -t "{session_name}:{w.window_index}" """, hide=True)
        pass


if __name__ == "__main__":
    cmd = sys.argv[1]
    cmd = cmd.replace("-", "_").removeprefix("tmux_")
    out = X().__getattribute__(cmd)(*sys.argv[2:])
    if out:
        print(out)
