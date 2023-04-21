import wx


class MyFrame(wx.Frame):
    def __init__(self, parent, title):
        super(MyFrame, self).__init__(parent, title=title, size=(1200, 600))

        splitter = wx.SplitterWindow(self)
        left_panel = wx.Panel(splitter)
        right_panel = wx.Panel(splitter)

        self.tree = wx.TreeCtrl(left_panel)
        root = self.tree.AddRoot('Root')
        self.tree.AppendItem(root, 'long text--------------------------------------')
        self.tree.AppendItem(root, 'Item 2')
        self.tree.Expand(root)

        self.text_ctrl = wx.TextCtrl(right_panel, style=wx.TE_MULTILINE)
        self.text_ctrl.SetLabelText("firstRow\n\tsecondRow\nThirdRow\nfourthRow")
        self.button = wx.Button(right_panel, label='Click me')

        left_box = wx.BoxSizer(wx.VERTICAL)
        left_box.Add(self.tree, flag=wx.EXPAND | wx.ALL, border=5, proportion=11)
        left_panel.SetSizer(left_box)

        right_box = wx.BoxSizer(wx.VERTICAL)
        right_box.Add(self.text_ctrl, flag=wx.EXPAND | wx.ALL, border=5, proportion=1)
        right_box.Add(self.button, 0, wx.ALIGN_CENTER | wx.ALL, 5)
        right_panel.SetSizer(right_box)

        splitter.SplitVertically(left_panel, right_panel)
        splitter.SetMinimumPaneSize(100)
        splitter.SetSashPosition(500)  # 设置分割线位置

        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(splitter, 15, wx.EXPAND | wx.ALL, 2)

        self.SetSizer(vbox)

        self.button.Bind(wx.EVT_BUTTON, self.clear_and_rebuild_tree)

        self.Show(True)

    def clear_and_rebuild_tree(self, event):
        root = self.tree.GetRootItem()
        self.tree.DeleteChildren(root)

        text = self.text_ctrl.GetValue()
        lines = text.split('\n')
        prev_indent = -1
        prev_item = root
        indentMap = {}  # item: indent，记录每个缩进最后一个item
        treeItemList = []  # 记录所有item
        for line in lines:
            stripped = line.lstrip()
            if not stripped:
                continue
            indent = len(line) - len(stripped)
            # print(line, " indent: ", indent, "prev_indent: ", prev_indent)
            if indent == prev_indent:
                parent_item = self.tree.GetItemParent(prev_item)
                item = self.tree.AppendItem(parent_item, stripped)
            else:
                if indent < prev_indent:
                    # 往前找第一个比自己indent小的item，作为自己的parent
                    for i in range(len(treeItemList) - 1, -1, -1):
                        item_indent = indentMap[treeItemList[i]]
                        if item_indent < indent:
                            item = self.tree.AppendItem(treeItemList[i], stripped)
                            break
                else:  # indent > prev_indent 加到上一个item的子节点
                    item = self.tree.AppendItem(prev_item, stripped)

            prev_indent, prev_item = indent, item
            indentMap[item] = indent
            treeItemList.append(item)

        self.tree.ExpandAll()


app = wx.App(False)
frame = MyFrame(None, 'TextToTreeView')
app.MainLoop()
