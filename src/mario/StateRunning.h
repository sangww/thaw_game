#pragma once

#include <cmath>
#include <list>
//#include "State.h"
#include "AssetManager.h"
#include "Player.h"
#include "Monster.h"
#include "Map.h"

//class StateManager;

class StateRunning {

public:	
	StateRunning();
	virtual ~StateRunning();

	//virtual void setup(StateManager* manager);
	virtual void setup(string xml, string xmlmap);
	virtual void draw(float scaleX=1.f, float scaleY=1.f);
	virtual void update(float px, float py, float pw, float ph, float angle);
    
    int get1X(){ return player1->getX();};
    int get1Y(){ return player1->getY();};
    int get1VX(){ return player1->getVelX();};
    int get1VY(){ return player1->getVelY();};
    void set1X(float p){ return player1->setX(p);};
    void set1Y(float p){ return player1->setY(p);};
    void set1VX(float v){ return player1->setVelX(v);};
    void set1VY(float v){ return player1->setVelY(v);};
    void kill1(){ player1->kill();};
    
    void set1Move(float m, float j){player1->setMove(m, j);};
    
	void keyPressed(int k);
	void keyReleased(int k);
	
    void teleportPlayer1(bool come, int x, int y, int vx, int vy);
    bool pipeAnimation;
	void setEntry(bool up, bool down, bool left, bool right);
    bool isPlayer1Here;
    
	AssetManager* assets;
    
private:
    
	void keyHandle(bool pressed, int key);
	void updateScroll(ofPoint& scroll, Player* player);
	bool charCollision(Character* char1, Character* char2);

	Player* player1;
	//Player* player2;
    

	list<Monster*> monsters;
	int monsterCount;

	Map* map;
	string bgSound;

	// scroll coords of the players:
	ofPoint scroll1; //scroll2;

	// scale depending on vertical/horizontal screen division:
	float scaleFactorX;
	float scaleFactorY;

	// movement state of the players:
	bool left1, up1, right1, down1;
	//bool left2, up2, right2, down2;
};
