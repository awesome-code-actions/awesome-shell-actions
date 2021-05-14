#!/bin/env crystal

class ShellOutput
  def initialize(raw : String)
    @raw = raw
  end

  def lines : Array(String)
    return @raw.lines
  end

  def raw : String
    return @raw
  end
end

def r(cmd : String) : ShellOutput
  stdout = IO::Memory.new
  stderr = IO::Memory.new
  status = Process.run("bash", args: ["-c", cmd], output: stdout, error: stderr)
  if status.success?
    ShellOutput.new stdout.to_s
  else
    puts status.exit_code, stderr.to_s
    exit 1
  end
end

if ARGV.size != 2
  puts "you must point out file and text"
  exit 1
end

def list_commits_which_contains_file(file : String) : Array(String)
  return r(%{git --no-pager log --all  --pretty=format:"%h" --follow #{file}}).lines
end

def show_file_in_commit(commit : String, file : String) : String
  return r(%{git --no-pager show #{commit}:#{file}}).raw
end

def list_tag_which_contains_commit(commit : String) : Array(String)
  return r(%{git --no-pager tag --contains #{commit}}).lines
end

file = ARGV[0]
text = ARGV[1]

outs = list_commits_which_contains_file(file).flat_map { |commit|
  if show_file_in_commit(commit, file).includes?(text)
    list_tag_which_contains_commit(commit)
  else
    [] of String
  end
}
  .to_set
  .to_a
  .sort
  .each { |tag| puts tag }

puts outs
