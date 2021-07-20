

# Ranking class (this class keeps only specified number of items)
# basic order: Desc
class Ranking(object):
    size = 10
    key = None
    items = []
    order = 1

    def __init__(self, _size, _key=None, _order="DESC"):
        self.size = _size
        self.key = _key
        self.items = []

        if _order.upper()=="ASC":
            self.order = -1
        elif _order.upper()=="DESC":
            self.order = 1
        else:
            raise Exception("Unknown parameter in order")

    def add(self, _item):
        # for the initial
        if len(self.items)==0:
            self.items.append(_item)
            return True

        # find locate to add and insert
        flag = False
        if self.key is None:
            for x in range(0, len(self.items)):
                if _item > self.items[x] * self.order:
                    self.items.insert(x, _item)
                    flag = True
                    break
        else:
            for x in range(0, len(self.items)):
                if _item[self.key] * self.order > self.items[x][self.key] * self.order:
                    self.items.insert(x, _item)
                    flag = True
                    break

        # keep the size of the item list
        if len(self.items)>self.size:
            self.items = self.items[0:self.size]
        else:
            if flag is False:
                self.items.append(_item)

        return True

    def getAll(self):
        return self.items
