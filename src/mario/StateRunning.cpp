#include "StateRunning.h"

StateRunning::StateRunning():
	player1(new Player()),	map(new Map()) {
}

StateRunning::~StateRunning()
{
	delete player1;
	delete map;
}

void StateRunning::setup(string xml, string xmlmap)
{
    isPlayer1Here = true;
    
	assets = AssetManager::exemplar();
    
	assets->setup(xml, xmlmap);
    
	map->initMap(xmlmap);
    
	player1->init(xml, "PLAYER_1");
    
	//initialize monsters
	monsterCount = 0;
	for(int i = 1; i <= monsterCount; i++) {
		int x = map->getWidth() / monsterCount * i;
		int y = 0;
		Monster* monstrPtr = new Monster(x, y);
		monsters.push_back(monstrPtr);
		monsters.back()->init(xml, "ENEMY_1");
	}
    
	scroll1.set(0, 0, 0);
    
	scaleFactorX = 1;
	scaleFactorY = 1;
    
	left1 = up1 = right1 = down1 = false;
    
	//set background-color to default smb-blue
	ofBackground(60, 100, 252);
}

void StateRunning::update(float px, float py, float pw, float ph, float angle)
{
    if(!isPlayer1Here) return;
    
    if(up1){
        int x1 = player1->getX();
        int y1 = player1->getY();
        if(x1>1329 && x1<1354 && y1>180 && y1< 185){
            //nextStage(_manager);
        }
    }
    
	// update player-position and scroll coords:
	if(!pipeAnimation)player1->move(left1, up1, right1, down1, map, px, py, pw, ph, angle);

	float gravity = player1->getGravity();
	for(list<Monster*>::iterator it = monsters.begin();
		it != monsters.end();) {

		(*it)->move(map);

		if((*it)->getStatus() != dead &&
		   (*it)->getStatus() != dying) {
			if(charCollision(player1, (*it)) &&
				player1->getStatus() != dead) {
				//if player is moving down
				if(player1->getVelY() > gravity) {
					player1->bounce();
					(*it)->bruise();
				}
				else
					player1->kill();
			}
		}

		if((*it)->getStatus() == dead) {
			   it = monsters.erase(it);
			   continue;
		}
		else
			it++;

	} // end of for-loop
}

void StateRunning::draw(float scaleX, float scaleY)
{
	//upper half window, player 1:
	glViewport(0, 0, ofGetWidth()+2, ofGetHeight());
	glPushMatrix();
	ofEnableAlphaBlending();
	ofTranslate(scroll1.x * scaleFactorX, scroll1.y * scaleFactorY);
	gluOrtho2D(0, 2, 0, 2);
    
	// draw player one in the front:
	if(isPlayer1Here) player1->draw(assets, scaleX, scaleY);

	map->draw(scroll1.x, scroll1.y, ofGetWidth(), ofGetHeight(), assets);

	for(list<Monster*>::iterator it = monsters.begin();
		it != monsters.end(); it++) {

		(*it)->draw(assets);
	}
	
	ofDisableAlphaBlending();
	glPopMatrix();

    /*
	//viewport-overlay for misc. output
	glViewport(0, 0, ofGetWidth(), ofGetHeight());
	glPushMatrix();
	ofPushStyle();
    //
	ofPopStyle();
	glPopMatrix();
     */
}


void StateRunning::keyPressed(int k)
{
	keyHandle(true, k);
}

void StateRunning::keyReleased(int k)
{
	keyHandle(false, k);
}

void StateRunning::keyHandle(bool pressed, int key) {

	// handle controls:
	key = tolower(key);
	switch(key) {
	case OF_KEY_LEFT:
		left1 = pressed;
		break;
	case OF_KEY_UP:
		up1 = pressed;
		break;
	case OF_KEY_RIGHT:
		right1 = pressed;
		break;
	case OF_KEY_DOWN:
		down1 = pressed;
		break;
            
	default:
		//cout << key << endl;
		break;
	}
}

bool StateRunning::charCollision(Character* char1, Character* char2) {
	int left1, left2;
	int right1, right2;
	int top1, top2;
	int bottom1, bottom2;

	left1 = char1->getX();
	left2 = char2->getX();
	right1 = left1 + char1->getWidth();
	right2 = left2 + char2->getWidth();

	top1 = char1->getY();
	top2 = char2->getY();
	bottom1 = top1 + char1->getHeight();
	bottom2 = top2 + char2->getHeight();
	
	//the first 4 cases are the ones
	//where intersection is impossible
	if(right1 < left2) {
		return false;
	}
	else if(bottom1 < top2) {
		return false;
	}
	else if(left1 > right2) {
		return false;
	}
	else if(top1 > bottom2) {
		return false;
	}
	//so here we must have a collision
	else {
		return true;
	}
}

void StateRunning::updateScroll(ofPoint& scroll, Player* player) {

	// keep every player in the center of his screen-half:
	scroll.x = -player->getX() + ofGetWidth() / (scaleFactorX * 2);
	scroll.y = -player->getY() + ofGetHeight() / (scaleFactorY * 2);

	// don't scroll out of the map-boundaries:
	if(scroll.x > 0)
		scroll.x = 0;
	else if(scroll.x < (-map->getWidth() + ofGetWidth() / scaleFactorX))
		scroll.x = -map->getWidth() + ofGetWidth() / scaleFactorX;

	if(scroll.y > 0)
		scroll.y = 0;
	else if(scroll.y < -map->getHeight() + ofGetHeight() / scaleFactorY)
		scroll.y = -map->getHeight() + ofGetHeight() / scaleFactorY;

}

void StateRunning::setEntry(bool up, bool down, bool left, bool right){
    player1->entryUp = up;
    player1->entryDown = down;
    player1->entryLeft = left;
    player1->entryRight = right;
}


void StateRunning::teleportPlayer1(bool come, int x, int y, int vx, int vy){
    isPlayer1Here = come;
    if(isPlayer1Here){
        player1->setX(x);
        player1->setY(y);
        player1->setVelX(vx);
        player1->setVelY(vy);
        player1->reset();
    }
}