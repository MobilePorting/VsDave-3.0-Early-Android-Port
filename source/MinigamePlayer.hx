package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class MinigamePlayer extends FlxSprite
{
    static inline var speed:Float = 220;

    public static var up:Bool = false;
    public static var down:Bool = false;
    public static var left:Bool = false;
    public static var right:Bool = false;

    public var lockMovement:Bool = false;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);

        makeGraphic(16, 16, FlxColor.BLUE);
        drag.x = drag.y = 1600;
    }

    override function update(elapsed:Float)
    {
        updateHitbox();
        
        if (!lockMovement)
            updateMovement();

        super.update(elapsed);
    }

    function updateMovement()
    {
        if (up && down)
            up = down = false;
        if (left && right)
            left = right = false;

        if (up || down || left || right)
        {
            var newAngle:Float = 0;
            if (up)
            {
                newAngle = -90;
                if (left)
                    newAngle -= 45;
                else if (right)
                    newAngle += 45;
            }
            else if (down)
            {
                newAngle = 90;
                if (left)
                    newAngle += 45;
                else if (right)
                    newAngle -= 45;
            }
            else if (left)
                newAngle = 180;
            else if (right)
                newAngle = 0;

            velocity.set(speed, 0);
            velocity.rotate(FlxPoint.weak(0, 0), newAngle);
        }
    }
}
