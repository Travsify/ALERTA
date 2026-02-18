Add-Type -AssemblyName System.Drawing

function Generate-Icon {
    param (
        [string]$Path,
        [string]$BgColor,
        [string]$MainColor,
        [string]$InnerColor
    )

    $bmp = New-Object System.Drawing.Bitmap 512, 512
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    
    # Background
    $bgBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($BgColor))
    $g.FillRectangle($bgBrush, 0, 0, 512, 512)

    # Shackle
    $mainPen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml($MainColor)), 40
    $mainPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $mainPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    
    # Simple arc for shackle
    $rect = New-Object System.Drawing.Rectangle 156, 40, 200, 200
    $g.DrawArc($mainPen, $rect, 180, 180)
    $g.DrawLine($mainPen, 156, 140, 156, 180)
    $g.DrawLine($mainPen, 356, 140, 356, 180)

    # Shield
    $shieldPoints = @(
        (New-Object System.Drawing.Point 80, 160),
        (New-Object System.Drawing.Point 80, 280),
        (New-Object System.Drawing.Point 256, 460),
        (New-Object System.Drawing.Point 432, 280),
        (New-Object System.Drawing.Point 432, 160)
    )
    $mainBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($MainColor))
    $g.FillPolygon($mainBrush, $shieldPoints)

    # Inner Pulse A
    $pulsePen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml($InnerColor)), 25
    $pulsePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pulsePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pulsePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    # The A frame
    $g.DrawLine($pulsePen, 256, 220, 180, 360)
    $g.DrawLine($pulsePen, 256, 220, 332, 360)

    # The Pulse horizontal
    $pulsePoints = @(
        (New-Object System.Drawing.Point 180, 300),
        (New-Object System.Drawing.Point 220, 300),
        (New-Object System.Drawing.Point 240, 270),
        (New-Object System.Drawing.Point 272, 330),
        (New-Object System.Drawing.Point 292, 300),
        (New-Object System.Drawing.Point 332, 300)
    )
    $g.DrawLines($pulsePen, $pulsePoints)

    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

# Generate Launcher Icon (Blue on White/Trans)
Generate-Icon -Path "c:\Users\USER\Desktop\Alerta\alerta_mobile\assets\icon\alerta_launcher_icon.png" -BgColor "#FFFFFF" -MainColor "#0047AB" -InnerColor "#FFFFFF"

# Generate Splash Icon (White on Blue)
Generate-Icon -Path "c:\Users\USER\Desktop\Alerta\alerta_mobile\assets\icon\alerta_splash_image.png" -BgColor "#0047AB" -MainColor "#FFFFFF" -InnerColor "#0047AB"
