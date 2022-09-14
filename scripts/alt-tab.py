import os
import json
raw= open("/tmp/alt-tab.raw").read()
# print(raw)
if not raw.startswith("(true,"):
    os.abort()
raw=raw.strip().lstrip("(true,").rstrip(")").strip()
if raw.startswith("'"):
    raw=raw.strip("'")
if raw.startswith('"'):
    raw=raw.strip('"')
raw_text=""
index=0
for b in raw.split("0x"):
    index=index+1
    braw=b.replace("0x","")
    if len(braw)>2:
        continue
    braw_bytes=bytes.fromhex(braw)
    try:
        text=braw_bytes.decode("utf-8")
        raw_text+=text
        print(braw_bytes,braw,index,text)
    except Exception as inst:
        pass
        # ignore

# print(raw_text)
raw_json=json.loads(raw_text)
open("/tmp/alt-tab.json","w").write(json.dumps(raw_json))