#Requires AutoHotkey v2.0

; 创建GUI
myGui := Gui()
myGui.Title := "配置文件快捷入口"
yPos := 10  ; 初始Y坐标

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
    myGui.Add("GroupBox", "x" groupBoxX " y" groupBoxY " w" groupWidth " h" groupHeight, section)
    
    ; 添加按钮
    currentRow := 0
    currentCol := 0
    for key, path in sectionData {
        ; 计算按钮坐标
        btnX := groupBoxX + startX + currentCol*(buttonWidth + marginX)
        btnY := groupBoxY + startY + currentRow*(buttonHeight + marginY)
        
        ; 创建按钮并绑定事件
        btn := myGui.Add("Button", "x" btnX " y" btnY " w" buttonWidth, key)
        btn.OnEvent("Click", EventHandler.Bind(path))
        
        ; 更新行列计数器
        if (++currentCol >= 3) {
            currentCol := 0
            currentRow++
        }
    }
    
    ; 更新下一个分组的Y坐标
    yPos := groupBoxY + groupHeight + 20
}

; 显示GUI
myGui.Show()

; 按钮点击事件处理
EventHandler(path, *) {
    try Run('"' path '"')  ; 处理带空格的路径
    catch Error as e {
        MsgBox "无法打开路径：`n" path "`n错误信息：" e.Message
    }
}
