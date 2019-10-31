[CmdletBinding()]
param()

## Class to hold a 3d point
class Point
{    
    Point($xCoord, $yCoord, $zCoord)
    {
        $this.X = $xCoord
        $this.Y = $yCoord
        $this.Z = $zCoord
    }

    [double] $X 
    [double] $Y
    [double] $Z
}

## Class that represents a 3d object that can be populated, rotated, and drawn.
class GraphicObject
{
    ## Creates an instance of the GraphicObject class with no default
    ## points.
    GraphicObject()
    {
        $this.Points = [System.Collections.Generic.List[Point]]::New()
        $this._backBuffer = " " * ([Console]::WindowWidth * ([Console]::WindowHeight - 1))
    }
    
    ## The list of points in this object
    [System.Collections.Generic.List[Point]] $Points

    ## A virtual console buffer to make updates appear smoother
    [char[]] $_backBuffer

    ## Some scale factors to account for console dimensions and character aspect
    ## ratios
    $Transpose = ([Console]::WindowWidth / 2), ([Console]::WindowHeight / 2)
    $Scale = 2, 2
    $CharacterType = [CharacterType]::Dot


    ## Draws the object
    [Void] Draw()
    {
        $pointList = [System.Collections.Generic.List[Point]]::New()
        foreach($point in $this.Points)
        {
            $pointlist.Add( [Point]::New( $point.X, $point.Y, $point.Z ))
        }

        $this.Draw($pointlist, $this.CharacterType)
    }

    ## Draws the object with the given character type
    [Void] Draw($PointsToDraw, [CharacterType] $character)
    {
        $this._backBuffer = " " * ([Console]::WindowWidth * ([Console]::WindowHeight - 1))

        ## Map the enum to an actual character
        $charToDraw = switch($character)
        {
            ([CharacterType]::Dot) { '.' }
            ([CharacterType]::Star) { '*' }
        }

        ## Iterate through the points in the object. We do this from far to near, although
        ## it doesn't actually matter in this example.
        foreach($point in $PointsToDraw | Sort-Object -Descending -Property Z)
        {
            $this._PutPixel($point.X, $point.Y, $point.Z, $charToDraw)
        }

        ## Replace the console text with what we drew to the background buffer
        [Console]::SetCursorPosition(0,0)
        [Console]::Write($this._backBuffer)
    }

    ## Rotates the object along x, y, and z.
    [void] Rotate($xDegrees, $yDegrees, $zDegrees)
    {
        $xRadians = $this._DegreesToRadians($xDegrees)
        $yRadians = $this._DegreesToRadians($yDegrees)
        $zRadians = $this._DegreesToRadians($zDegrees)

        foreach($point in $this.Points)
        {
            ## Rotate on X
            $oldX = $point.X
            $oldY = $point.Y
            $oldZ = $point.Z

            $point.Y = [Math]::Cos($xRadians) * $oldY -
                       [Math]::Sin($xRadians) * $oldZ

            $point.Z = [Math]::Sin($xRadians) * $oldY +
                       [Math]::Cos($xRadians) * $oldZ

            ## Rotate on Y
            $oldX = $point.X
            $oldY = $point.Y
            $oldZ = $point.Z

            $point.X = [Math]::Cos($yRadians) * $oldX -
                       [Math]::Sin($yRadians) * $oldZ

            $point.Z = [Math]::Sin($yRadians) * $oldX +
                       [Math]::Cos($yRadians) * $oldZ


            ## Rotate on Z
            $oldX = $point.X
            $oldY = $point.Y
            $oldZ = $point.Z

            $point.X = [Math]::Cos($zRadians) * $oldX -
                       [Math]::Sin($zRadians) * $oldY

            $point.Y = [Math]::Sin($zRadians) * $oldX +
                       [Math]::Cos($zRadians) * $oldY
        }               
    }

    ## Helper function to write a character to the screen in the given location
    [void] _PutPixel($x, $y, $z, $character)
    {
        $scaledX = [int] ($x  * $this.scale[0] + $this.transpose[0])
        $scaledY = [int] ($y  * (3/4) * $this.scale[1] + $this.transpose[1])

        ## If we wanted to account for perspective or camera distance,
        ## we would apply that to X and Y based on the Z coordinate. Skip
        ## that for simplicity.

        $this._backBuffer[([Console]::WindowWidth * $scaledY) + $scaledX] = $character
    }

    ## Helper function to convert degrees to radians
    [double] _DegreesToRadians($degrees)
    {
        return $degrees / 180 * [Math]::Pi
    }

    ## Static methods to return interesting object types
    static [GraphicObject] Box()
    {
        $object = [GraphicObject]::New()
        $min = -1 * [Console]::WindowHeight / 3
        $max = [Console]::WindowHeight / 3
        for($x = $min; $x -lt $max; $x++)
        {
            $object.Points.Add([Point]::New($x, $min, $min))
            $object.Points.Add([Point]::New($x, $max, $min))
            $object.Points.Add([Point]::New($x, $min, $max))
            $object.Points.Add([Point]::New($x, $max, $max))
        }

        for($y = $min; $y -lt $max; $y++)
        {
            $object.Points.Add([Point]::New($min, $y, $min))
            $object.Points.Add([Point]::New($max,$y, $min))
            $object.Points.Add([Point]::New($min, $y, $max))
            $object.Points.Add([Point]::New($max, $y, $max))
        }

        for($z = $min; $z -lt $max; $z++)
        {
            $object.Points.Add([Point]::New($min, $min, $z))
            $object.Points.Add([Point]::New($max, $min, $z))
            $object.Points.Add([Point]::New($min, $max, $z))
            $object.Points.Add([Point]::New($max, $max, $z))
        }

        $object.Transpose = ([Console]::WindowWidth / 2), ([Console]::WindowHeight / 2)

        $scaleFactor = [Console]::WindowHeight / ($max - $min) * 2/3
        $object.Scale = $scaleFactor, $scaleFactor
        return $object
    }

    static [GraphicObject] Saddle()
    {
        $object = [GraphicObject]::New()
        $min = -1
        $max = 1
        $increment = 0.15
        for($x = $min; $x -lt $max; $x += $increment)
        {
            for($y = $min; $y -lt $max; $y += $increment)
            {
                $object.Points.Add([Point]::New($x, $y, ($x * $x) - ($y * $y)))
            }
        }

        $object.Transpose = ([Console]::WindowWidth / 2), ([Console]::WindowHeight / 2)

        $scaleFactor = [Console]::WindowHeight / ($max - $min) * 2/3
        $object.Scale = $scaleFactor, $scaleFactor
        return $object
    }

    static [GraphicObject] Helix()
    {
        $object = [GraphicObject]::New()

        $rotationDegrees = 0
        for($z = -1; $z -lt 1; $z += 0.01)
        {
            $object.Points.Add([Point]::New([Math]::Sin($rotationDegrees), [Math]::Cos($rotationDegrees), $z))
            $rotationDegrees += 0.1 % (2 * [Math]::Pi)
        }

        $object.Transpose = ([Console]::WindowWidth / 2), ([Console]::WindowHeight / 2)

        $scaleFactor = [Console]::WindowHeight / 3
        $object.Scale = $scaleFactor, $scaleFactor
        return $object
    }

    static [GraphicObject] PowerShell()
    {
        $centerX = 115
        $centerY = 168

        $max = 180
        $min = 1

        $object = [GraphicObject]::New()

        foreach($zIndex in -10,0,10)
        {
            [System.Collections.Generic.List[Point]] $newPoints = 
                [GraphicObject]::DrawLine(74 - $centerX, 196 - $centerY, 194 - $centerX, 113 - $centerY, $zIndex)
            $object.Points.AddRange($newPoints)


            [System.Collections.Generic.List[Point]] $newPoints = 
                [GraphicObject]::DrawLine(106 - $centerX, 34 - $centerY, 194 - $centerX, 113 - $centerY, $zIndex)
            $object.Points.AddRange($newPoints)

            [System.Collections.Generic.List[Point]] $newPoints = 
                [GraphicObject]::DrawLine(134 - $centerX, 186 - $centerY, 204 - $centerX, 186 - $centerY, $zIndex)
            $object.Points.AddRange($newPoints)
        }

        $scaleFactor = [Console]::WindowHeight / ($max - $min) * 2/3
        $object.Scale = $scaleFactor, $scaleFactor
        return $object
    }
    
    ## Basic implementation of the Bresenham line drawing algorithm
    static [System.Collections.Generic.List[Point]] DrawLine($startX, $startY, $endX, $endY, $zIndex)
    {
        [System.Collections.Generic.List[Point]] $newPoints = 
            [System.Collections.Generic.List[Point]]::New()

        $deltaX = $endX - $startX
        $deltaY = $endY - $startY
        $error = 0
        $deltaError = [Math]::Abs($deltaY / $deltaX)

        $y = $startY
        $yIncr = 1;
        $xIncr = 1;
        $xCount = [Math]::Abs($endX - $startX)

        if($endY -lt $startY) { $yIncr = -1 }
        if($endX -lt $startX) { $xIncr = -1 }

        $x = $startX
        while($xCount -gt 0)
        {
            $newPoints.Add( ([Point]::New($x, $y, $zIndex)) )
            $error =  $error + $deltaError
            if($error -gt 0.5)
            {
                $y += $yIncr
                $error--
            }

            $xCount--
            $x +=$xIncr
        }

        return $newPoints
    }
}

## call.
enum CharacterType
{
    Dot = 0
    Star = 1
}


## Now play with the objects
cls

## The GraphicObject class has three static factory methods to generate
## interesting versions of itself. Store these so that we can cycle through
## them with the TAB key.
$objects = "Saddle", "PowerShell", "Box", "Helix"
$currentObject = 0
$object = [GraphicObject]::($objects[$currentObject]).Invoke()


$startTime = Get-Date
$frames = 0

$xRot = 1
$yRot = 1
$zRot = 2

$shouldExit = $false
while(-not $shouldExit)
{
    if([Console]::KeyAvailable)
    {
        $key = [Console]::ReadKey()

        switch($key.Key)
        {
            ## Change rotation speed
            RightArrow { $yRot++ }
            LeftArrow { $yRot-- }
            DownArrow { $xRot-- }
            UpArrow { $xRot++ }
            SpaceBar {
                $xRot, $yRot, $zRot = 1..3 | % { Get-Random -Min -5 -Max 5 }
            }
            P { $xRot, $yRot, $zRot = 0, 0, 0 }

            ## Change drawing characters
            D8 { $object.CharacterType = "Star" }
            OemPeriod { $object.CharacterType = "Dot" }

            ## Change objects
            Tab {
                $currentObject = ($currentObject + 1) % $objects.Length
                $object = [GraphicObject]::($objects[$currentObject]).Invoke()
            }

            ## Quit
            Q { $shouldExit = $true }

            default { if($PSBoundParameters["Debug"]) { $host.EnterNestedPrompt() } }
        }
    }

    $object.Draw()
    $object.Rotate($xRot, $yRot, $zRot)
    $frames++
}

$endTime = Get-Date
if($PSBoundParameters['Debug']) { "`r`nFrame rate: {0} FPS" -f ($frames / ($endTime - $startTime).TotalSeconds) }