from invoke import Program,Collection
from . import virt
if __name__ == "__main__":
    cls=Collection()
    cls.add_collection(virt)
    program = Program(name="virt",version='0.0.0',namespace=cls)
    program.run()
    pass