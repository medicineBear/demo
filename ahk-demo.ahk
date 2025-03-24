#Requires AutoHotkey v2.0

; 主GUI
mainGui := Gui()
mainGui.Title := "配置文件快捷入口"
mainGui.OnEvent("Close", GuiClose)
yPos := 10  ; 初始Y坐标

; 添加按钮用于打开添加新项的GUI
addBtn := mainGui.Add("Button", "x10 y10 w100 h30", "添加新项")
addBtn.OnEvent("Click", ShowAddItemGui)

; 读取并显示现有配置
ReadAndShowConfig(mainGui)

; 显示主GUI
mainGui.Show()

; 关闭事件
GuiClose(*) {
    ExitApp
}

; 读取配置并显示按钮
ReadAndShowConfig(guiObj) {
    static lastGroupBoxY := 0
    
    ; 清除现有控件（除了"添加新项"按钮）
    for ctl in guiObj {
        if ctl != addBtn {
            ctl.Destroy()
        }
    }
    
    yPos := 50  ; 从添加按钮下方开始
    
    ; 读取配置文件所有节
    sections := []
    Loop Read, "config.ini" {
        if RegExMatch(A_LoopReadLine, "^\[(.*)\]$", &match) {
            sections.Push(match[1])
        }
    }

    ; 遍历所有节
    for section in sections {
        ; 读取当前节的所有键值对
        sectionData := IniRead("config.ini", section)
        if sectionData.Count = 0
            continue
        
        ; 计算布局参数
        buttonWidth := 100
        buttonHeight := 30
        marginX := 10
        marginY := 10
        startX := 10   ; GroupBox内部左边距
        startY := 20   ; GroupBox内部上边距
        
        ; 计算分组框尺寸
        totalButtons := sectionData.Count
        rows := Ceil(totalButtons / 3)
        groupWidth := 3*buttonWidth + 2*marginX + 2*startX
        groupHeight := startY + rows*(buttonHeight + marginY) + 10
        
        ; 添加分组框
        groupBoxX := 10
        groupBoxY := yPos
        guiObj.Add("GroupBox", "x" groupBoxX " y" groupBoxY " w" groupWidth " h" groupHeight, section)
        
        ; 添加按钮
        currentRow := 0
        currentCol := 0
        for key, path in sectionData {
            ; 计算按钮坐标
            btnX := groupBoxX + startX + currentCol*(buttonWidth + marginX)
            btnY := groupBoxY + startY + currentRow*(buttonHeight + marginY)
            
            ; 创建按钮并绑定事件
            btn := guiObj.Add("Button", "x" btnX " y" btnY " w" buttonWidth, key)
            btn.OnEvent("Click", EventHandler.Bind(path))
            
            ; 更新行列计数器
            if (++currentCol >= 3) {
                currentCol := 0
                currentRow++
            }
        }
        
        ; 更新下一个分组的Y坐标
        yPos := groupBoxY + groupHeight + 20
        lastGroupBoxY := yPos
    }
}

; 显示添加新项的GUI
ShowAddItemGui(*) {
    addGui := Gui()
    addGui.Title := "添加新项"
    addGui.Opt("+Owner" mainGui.Hwnd)  ; 设置主窗口为所有者
    
    ; 添加控件
    addGui.Add("Text", "x10 y10", "分组名称:")
    sectionEdit := addGui.Add("Edit", "x80 y10 w200")
    
    addGui.Add("Text", "x10 y40", "按钮名称:")
    keyEdit := addGui.Add("Edit", "x80 y40 w200")
    
    addGui.Add("Text", "x10 y70", "文件路径:")
    pathEdit := addGui.Add("Edit", "x80 y70 w200")
    browseBtn := addGui.Add("Button", "x290 y70 w60", "浏览...")
    browseBtn.OnEvent("Click", BrowseFile.Bind(pathEdit))
    
    ; 添加确认和取消按钮
    confirmBtn := addGui.Add("Button", "x80 y110 w100", "确认")
    confirmBtn.OnEvent("Click", AddNewItem.Bind(sectionEdit, keyEdit, pathEdit, addGui))
    cancelBtn := addGui.Add("Button", "x190 y110 w100", "取消")
    cancelBtn.OnEvent("Click", (*) => addGui.Destroy())
    
    addGui.Show()
}

; 浏览文件
BrowseFile(editCtrl, *) {
    selectedFile := FileSelect(1, , "选择文件", "所有文件 (*.*)")
    if selectedFile != "" {
        editCtrl.Value := selectedFile
    }
}

; 添加新项
AddNewItem(sectionEdit, keyEdit, pathEdit, addGui, *) {
    section := sectionEdit.Value
    key := keyEdit.Value
    path := pathEdit.Value
    
    if section = "" || key = "" || path = "" {
        MsgBox("请填写所有字段", "错误", "Icon!")
        return
    }
    
    ; 写入配置文件
    try {
        IniWrite(path, "config.ini", section, key)
    } catch Error as e {
        MsgBox("写入配置文件失败: " e.Message, "错误", "Icon!")
        return
    }
    
    ; 关闭添加窗口
    addGui.Destroy()
    
    ; 重新加载配置
    ReadAndShowConfig(mainGui)
    
    MsgBox("添加成功!", "提示", "Iconi")
}

; 按钮点击事件处理
EventHandler(path, *) {
    try Run('"' path '"')  ; 处理带空格的路径
    catch Error as e {
        MsgBox "无法打开路径：`n" path "`n错误信息：" e.Message
    }
}
