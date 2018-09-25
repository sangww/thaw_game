#include "Player.h"

Player::Player():
	Character(),
	jumpheight(0),
	lockjump(false) {
}

void Player::derivedSetup() {
	// make the bounding box smaller than the sprite:
	width *= 0.8; // 80% of the sprite width.
	height *= 0.9; // 90% of the sprite height.

	jumpheight = 30;
	lockjump = false;
}

void Player::move(bool left, bool up, bool right, bool down, Map* map, float px, float py, float pw, float ph, float angle) {

	// update position every 10 milliseconds:
	if(ofGetElapsedTimeMillis() - timer >= 10) {
		switch(state) {
		case living:
			{
			int mapWidth, mapHeight;
			mapWidth = map->getWidth();
			mapHeight = map->getHeight();

			lastX = x;
			lastY = y;

			// larger values when program runs too slow to compensate:
			float step = moveSpeed * ((ofGetElapsedTimeMillis() - timer) / 10);
                
            if(velX >0){
                velX -= step;
                if(velX<0){
                    velX = 0;
                    velY = 0;
                }
            }
            else if(velX <0){
                velX +=step;
                if(velX>0){
                    velX = 0;
                    velY = 0;
                }
            }
                
			if(left)
				velX = -step;
			if(right)
				velX = step;
			if(up && !lockjump) {
				lockjump = true;
				velY = -jumpheight;
			}

			// dont let the player move faster than the tilesize,
			// or he could move through them without collision:
			velY = ofClamp(velY, -(map->getTileHeight() + 1),
						   map->getTileHeight() - 1);

			//reset the x & y-position according to
			//with what the player collides
			collisionHandling(map, px, py, pw, ph, angle);

			// dont let the player move out of the map boundaries:
			x = ofClamp(x, 0, mapWidth - width);
			y = ofClamp(y, 0, mapHeight - height);

			// pass the movement to the sprite:
			sprite.move(left, right, lockjump);

			timer = ofGetElapsedTimeMillis();
			}
			break;
		case dead:
			{
			//show killpic
			sprite.killPic(0, 0);
			//reset position and life after 3 seconds
			if(ofGetElapsedTimeMillis() - timer >= 3000) {
				x = 0;
				y = 0;
				state = living;
			}
			else {
				y += velY;
				velY += gravity;
			}
			}
			break;
		}
	}
}

void Player::collisionHandling(Map* map, float px, float py, float pw, float ph, float angle) {
	// used for moving the bounding box to the middle of the sprite:
	int xOffset = width / 8;
	int tilecoord;

	// moving right:
	if(velX > 0) {
		if(collision_ver((x + xOffset) + velX + width, y, tilecoord, map))
			x = tilecoord * map->getTileWidth() - width - 1 - xOffset;
        
        else if((!entryLeft) && (x+velX >= px - 10 && x <= px + 10 && y > py && y < py + ph)){
            x = px;
        }
        
		else
			x += velX;
	}
	// moving left:
	else if(velX < 0) {
		if(collision_ver((x + xOffset) + velX, y, tilecoord, map))
			x = (tilecoord + 1) * map->getTileWidth() + 1 - xOffset;
        
        else if((!entryRight) && (x+velX <= px + pw + 10 && x >= px + pw - 10 && y > py && y < py + ph)){
            x = px + pw;
        }
        
		else
			x += velX;
	}

	// moving up:
	if(velY < 0) {
		if(collision_hor((x + xOffset), y + velY, tilecoord, map)) {
			y = (tilecoord + 1) * map->getTileHeight() + 1;
			velY = 0;
		}
		else {
			y += velY;
			velY += gravity;
		}
	}
	// moving down:
	else {
		if(collision_hor((x + xOffset), y + velY + height, tilecoord, map)) {
			y = tilecoord * map->getTileHeight() - height - 1;
			velY = gravity;

			lockjump = false;
		}
        
        else if((!entryUp) && (y+velY >= py - 10 && y <= py + 10 && x > px && x < px + pw)){
            y = py;
            velY = gravity;
            lockjump = false;
        }
        
        else if((!entryUp) && (y >= py && y <= py + ph && x > px && x < px + pw)){
            y = py;
            velY = gravity;
            lockjump = false;
        }
        
		else {
			//if player touches the ground 
			//of the map he dies
			if(tilecoord == map->getGridY()) {
				kill();
			}
			else {
				y += velY;
				velY += gravity;

				lockjump = true;
			}
		}
	}
}

void Player::kill() {
	state = dead;
	timer = ofGetElapsedTimeMillis();
	bounce();
}

void Player::bounce() {
	velY = -jumpheight / 2;
}

void Player::reset(){
    timer = ofGetElapsedTimeMillis();
}
