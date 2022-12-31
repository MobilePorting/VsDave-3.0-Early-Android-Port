package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import mobile

class MinigamePlayer extends FlxSprite
{
    var virtualPad:FlxVirtualPad;

    static inline var speed:Float = 220;

    var up:Bool = false;
    var down:Bool = false;
    var left:Bool = false;
    var right:Bool = false;

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
        up = FlxG.keys.anyPressed([UP, W]) #if mobile || virtualPad.buttonUp.justPressed; #end
        down = FlxG.keys.anyPressed([DOWN, S]) #if mobile || virtualPad.buttonDown.justPressed; #end
        left = FlxG.keys.anyPressed([LEFT, A]) #if mobile || virtualPad.buttonLeft.justPressed; #end
        right = FlxG.keys.anyPressed([RIGHT, D]) #if mobile || virtualPad.buttonRight.justPressed; #end

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
