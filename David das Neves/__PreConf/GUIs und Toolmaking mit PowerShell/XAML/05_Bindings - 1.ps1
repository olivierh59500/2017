﻿#https://powerintheshell.com/2015/12/05/psgui-binding-examples
#requires -Version 2
<#  
        .NOTES 
        ============================================================================
        Date:       20.04.2017
        Presenter:  David das Neves 
        Version:    1.0
        Project:    PSConfEU - GUI 
        Ref:

        ============================================================================ 
        .DESCRIPTION 
        Presentation data        
#> 

function Convert-XAMLtoWindow
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $XAML,
         
        [string[]]
        $NamedElements,
         
        [switch]
        $PassThru
    )
     
    Add-Type -AssemblyName PresentationFramework
     
    $reader = [System.XML.XMLReader]::Create([System.IO.StringReader]$XAML)
    $result = [System.Windows.Markup.XAMLReader]::Load($reader)
    foreach($Name in $NamedElements)
    {
        $result | Add-Member -MemberType NoteProperty -Name $Name -Value $result.FindName($Name) -Force
    }
     
    if ($PassThru)
    {
        $result
    }
    else
    {
        $result.ShowDialog()
    }
}
 
$XAML = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    
   Name="Fenster"
   SizeToContent="WidthAndHeight"
    ResizeMode="CanResizeWithGrip"
   Title="PowerShell WPF Window"
   Topmost="True">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <Button Name="btnStop" Content="Stop" Grid.Column="4" HorizontalAlignment="Right" Margin="10" Grid.Row="4" VerticalAlignment="Bottom" Width="75"/>
        <ComboBox Name="cbbDienste" Grid.ColumnSpan="5" HorizontalAlignment="Left" Margin="10" VerticalAlignment="Top" Width="120" />
                <ListView Name="lvVariables" Grid.Column="2" Grid.Row="0" Margin="15,70,15,15" Height="500">
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="Name" Width="210" DisplayMemberBinding="{Binding Name}" />
                    <GridViewColumn Header="CPU" Width="250" DisplayMemberBinding="{Binding CPU}"/>
                </GridView>
            </ListView.View>
        </ListView>
        <ListView Grid.Column="4" Grid.Row="0" Name="lvEvents" Margin="15,70,25,15" >
            <ListView.View>
                <GridView>
                    <GridView.Columns>
                        <GridViewColumn>
                            <GridViewColumnHeader Content="Name" Width="Auto" MinWidth="200px"/>
                            <GridViewColumn.CellTemplate>
                                <DataTemplate>
                                    <TextBlock Text="{Binding Path=Name}" TextAlignment="Left" Width="Auto" FontWeight="{Binding Path=Set}" />
                                </DataTemplate>
                            </GridViewColumn.CellTemplate>
                        </GridViewColumn>
                    </GridView.Columns>
                </GridView>
            </ListView.View>
        </ListView>
    </Grid>
</Window>
'@
 
$window = Convert-XAMLtoWindow -XAML $XAML -NamedElements 'Fenster', 'btnStop', 'cbbDienste', 'lvVariables', 'lvEvents' -PassThru
  
$window.btnStop.add_Click(
    {
        [System.Object]$sender = $args[0]
        [System.Windows.RoutedEventArgs]$e = $args[1]   
        $prozesse = Get-Process | Select-Object -First 6
        $window.cbbDienste.ItemsSource = $prozesse
        Stop-Process -Name $window.cbbDienste.SelectedValue.Name
    }
)
 
$prozesse = Get-Process | Select-Object -First 20
 
#Binding by Memberpath
$window.cbbDienste.DisplayMemberPath = 'Name'
$window.cbbDienste.ItemsSource = $prozesse
$window.cbbDienste.SelectedIndex = 0
 
$window.ShowDialog()