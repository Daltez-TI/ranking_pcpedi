Attribute VB_Name = "gerar_tab_dinamicas_pcpedi"
Sub automatizar()
Attribute automatizar.VB_ProcData.VB_Invoke_Func = " \n14"
'
' automatizar Macro
'

'
    Application.CutCopyMode = False
    ActiveSheet.ListObjects.Add(xlSrcRange, Range("$A$1:$Z$2812"), , xlYes).Name = "Tabela2"

End Sub


Sub criando_tab_por_vendedor()
Attribute criando_tab_por_vendedor.VB_ProcData.VB_Invoke_Func = " \n14"
'
' criando_tab_dinamica Macro
'

'
    Application.CutCopyMode = False
    ActiveWorkbook.PivotCaches.Create(SourceType:=xlDatabase, SourceData:= _
        "meses_unificados", Version:=8).CreatePivotTable TableDestination:= _
        "TabD_porVendedor!R1C1", TableName:="Tabela dinâmica1", DefaultVersion:=8
    Sheets("TabD_porVendedor").Select
    Cells(1, 1).Select
    With ActiveSheet.PivotTables("Tabela dinâmica1")
        .ColumnGrand = True
        .HasAutoFormat = True
        .DisplayErrorString = False
        .DisplayNullString = True
        .EnableDrilldown = True
        .ErrorString = ""
        .MergeLabels = False
        .NullString = ""
        .PageFieldOrder = 2
        .PageFieldWrapCount = 0
        .PreserveFormatting = True
        .RowGrand = True
        .SaveData = True
        .PrintTitles = False
        .RepeatItemsOnEachPrintedPage = True
        .TotalsAnnotation = False
        .CompactRowIndent = 1
        .InGridDropZones = False
        .DisplayFieldCaptions = True
        .DisplayMemberPropertyTooltips = False
        .DisplayContextTooltips = True
        .ShowDrillIndicators = True
        .PrintDrillIndicators = False
        .AllowMultipleFilters = False
        .SortUsingCustomLists = True
        .FieldListSortAscending = False
        .ShowValuesRow = False
        .CalculatedMembersInFilters = False
        .RowAxisLayout xlCompactRow
    End With
    With ActiveSheet.PivotTables("Tabela dinâmica1").PivotCache
        .RefreshOnFileOpen = False
        .MissingItemsLimit = xlMissingItemsDefault
    End With
    ActiveSheet.PivotTables("Tabela dinâmica1").RepeatAllLabels xlRepeatLabels

    With ActiveSheet.PivotTables("Tabela dinâmica1").PivotFields("periodo")
        .Orientation = xlPageField
        .Position = 1
    End With
    With ActiveSheet.PivotTables("Tabela dinâmica1").PivotFields( _
        "Categoria_Cliente")
        .Orientation = xlColumnField
        .Position = 1
    End With
    With ActiveSheet.PivotTables("Tabela dinâmica1").PivotFields("vendedor")
        .Orientation = xlRowField
        .Position = 1
    End With

    ActiveSheet.PivotTables("Tabela dinâmica1").AddDataField ActiveSheet. _
        PivotTables("Tabela dinâmica1").PivotFields("total_vendas"), _
        "Soma de total_vendas", xlSum
    ActiveSheet.PivotTables("Tabela dinâmica1").AddDataField ActiveSheet. _
        PivotTables("Tabela dinâmica1").PivotFields("lucro_total"), _
        "Soma de lucro_total", xlSum

    With ActiveSheet.PivotTables("Tabela dinâmica1").DataPivotField
        .Orientation = xlRowField
        .Position = 2
    End With
End Sub


Sub criando_tab_por_rede()
'
' criando_tab_dinamica Macro
'

'
    Application.CutCopyMode = False
    ActiveWorkbook.PivotCaches.Create(SourceType:=xlDatabase, SourceData:= _
        "Acrescentar1", Version:=8).CreatePivotTable TableDestination:= _
        "TabD_porRede!R1C1", TableName:="TabD2", DefaultVersion:=8
    Sheets("TabD_porRede").Select
    Cells(1, 1).Select
    With ActiveSheet.PivotTables("TabD2")
        .ColumnGrand = True
        .HasAutoFormat = True
        .DisplayErrorString = False
        .DisplayNullString = True
        .EnableDrilldown = True
        .ErrorString = ""
        .MergeLabels = False
        .NullString = ""
        .PageFieldOrder = 2
        .PageFieldWrapCount = 0
        .PreserveFormatting = True
        .RowGrand = True
        .SaveData = True
        .PrintTitles = False
        .RepeatItemsOnEachPrintedPage = True
        .TotalsAnnotation = False
        .CompactRowIndent = 1
        .InGridDropZones = False
        .DisplayFieldCaptions = True
        .DisplayMemberPropertyTooltips = False
        .DisplayContextTooltips = True
        .ShowDrillIndicators = True
        .PrintDrillIndicators = False
        .AllowMultipleFilters = False
        .SortUsingCustomLists = True
        .FieldListSortAscending = False
        .ShowValuesRow = False
        .CalculatedMembersInFilters = False
        .RowAxisLayout xlCompactRow
    End With
    With ActiveSheet.PivotTables("TabD2").PivotCache
        .RefreshOnFileOpen = False
        .MissingItemsLimit = xlMissingItemsDefault
    End With
    ActiveSheet.PivotTables("TabD2").RepeatAllLabels xlRepeatLabels

    With ActiveSheet.PivotTables("TabD2").PivotFields("periodo")
        .Orientation = xlPageField
        .Position = 1
    End With
    With ActiveSheet.PivotTables("TabD2").PivotFields("Categoria_Cliente")
        .Orientation = xlColumnField
        .Position = 1
    End With
    With ActiveSheet.PivotTables("TabD2").PivotFields("rede")
        .Orientation = xlRowField
        .Position = 1
    End With

    ActiveSheet.PivotTables("TabD2").AddDataField ActiveSheet. _
        PivotTables("TabD2").PivotFields("lucro_total"), _
        "Soma de lucro_total", xlSum

End Sub


Sub criando_tab_por_Lucro()
'
' criando_tab_dinamica Macro
'

'
    Application.CutCopyMode = False
    ActiveWorkbook.PivotCaches.Create(SourceType:=xlDatabase, SourceData:= _
        "Acrescentar1", Version:=8).CreatePivotTable TableDestination:= _
        "TabD_porLucro!R1C1", TableName:="TabD", DefaultVersion:=8
    Sheets("TabD_porLucro").Select
    Cells(1, 1).Select
    With ActiveSheet.PivotTables("TabD")
        .ColumnGrand = True
        .HasAutoFormat = True
        .DisplayErrorString = False
        .DisplayNullString = True
        .EnableDrilldown = True
        .ErrorString = ""
        .MergeLabels = False
        .NullString = ""
        .PageFieldOrder = 2
        .PageFieldWrapCount = 0
        .PreserveFormatting = True
        .RowGrand = True
        .SaveData = True
        .PrintTitles = False
        .RepeatItemsOnEachPrintedPage = True
        .TotalsAnnotation = False
        .CompactRowIndent = 1
        .InGridDropZones = False
        .DisplayFieldCaptions = True
        .DisplayMemberPropertyTooltips = False
        .DisplayContextTooltips = True
        .ShowDrillIndicators = True
        .PrintDrillIndicators = False
        .AllowMultipleFilters = False
        .SortUsingCustomLists = True
        .FieldListSortAscending = False
        .ShowValuesRow = False
        .CalculatedMembersInFilters = False
        .RowAxisLayout xlCompactRow
    End With
    With ActiveSheet.PivotTables("TabD").PivotCache
        .RefreshOnFileOpen = False
        .MissingItemsLimit = xlMissingItemsDefault
    End With
    ActiveSheet.PivotTables("TabD").RepeatAllLabels xlRepeatLabels

    With ActiveSheet.PivotTables("TabD").PivotFields("periodo")
        .Orientation = xlPageField
        .Position = 1
    End With
    With ActiveSheet.PivotTables("TabD").PivotFields("Categoria_Cliente")
        .Orientation = xlColumnField
        .Position = 1
    End With
    With ActiveSheet.PivotTables("TabD").PivotFields("Cliente_Info")
        .Orientation = xlRowField
        .Position = 1
    End With

    ActiveSheet.PivotTables("TabD").AddDataField ActiveSheet. _
        PivotTables("TabD").PivotFields("lucro_total"), _
        "Soma de lucro_total", xlSum

End Sub


Sub muda_posicao_categorias()
'
' muda_posicao_categorias Macro
'

'
    ActiveSheet.PivotTables("TabD").PivotFields("Categoria_Cliente").PivotItems("AAA+").Position = 1
    ActiveSheet.PivotTables("TabD").PivotFields("Categoria_Cliente").PivotItems("AAA").Position = 2
    ActiveSheet.PivotTables("TabD").PivotFields("Categoria_Cliente").PivotItems("AA").Position = 3
End Sub
