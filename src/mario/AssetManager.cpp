#include "AssetManager.h"

AssetManager* AssetManager::instanz = 0;

AssetManager* AssetManager::exemplar() {
	if(instanz == 0)
		instanz = new AssetManager();
	return instanz;
}

AssetManager::AssetManager() {
	players.clear();
	tiles.clear();
	//sounds.clear();
    
	font.loadFont("HelveticaNeueMed.ttf", 70, true, true);
	font.setLineHeight(34.0f);
	font.setLetterSpacing(1.1);
}

void AssetManager::setup(string settingsFile, string mapFile) {
	// load XML-parser:
	ofxXmlSettings XML, XMLmap;

    if(!initialized){
        if(XML.loadFile(settingsFile)) {
            cout << "AssetManager: " << settingsFile << " successfully loaded!" << endl;
        }
        else {
            cout << "AssetManager: Couldn't load " << settingsFile << "!" << endl;
        }
        setup(XML);
        initialized = true;
    }
    
    if(XMLmap.loadFile(mapFile)) {
        cout << "AssetManager: " << mapFile << " successfully loaded!" << endl;
    }
    else {
        cout << "AssetManager: Couldn't load " << mapFile << "!" << endl;
    }
    setupMap(XMLmap);
}

void AssetManager::setup(ofxXmlSettings& XML) {
	// load character-images:
	string tempFileName = XML.getValue("GAME:MAP:PLAYERS:PLAYER_1:SPRITESHEET", "");
	if(addImage(tempFileName, tempFileName, CHARACTER))
		cout << "Added " << tempFileName << " to character-images" << endl;

	tempFileName = XML.getValue("GAME:MAP:PLAYERS:PLAYER_2:SPRITESHEET", "");
	if(addImage(tempFileName, tempFileName, CHARACTER))
		cout << "Added " << tempFileName << " to character-images" << endl;

	tempFileName = XML.getValue("GAME:MAP:PLAYERS:ENEMY_1:SPRITESHEET", "");
	if(addImage(tempFileName, tempFileName, CHARACTER))
		cout << "Added " << tempFileName << " to character-images" << endl;
}

void AssetManager::setupMap(ofxXmlSettings& XML) {
    
	// get grid-size of the map:
	int tileCountX = XML.getValue("GAME:MAP:GRID:X", 0);
	int tileCountY = XML.getValue("GAME:MAP:GRID:Y", 0);
    
	// load tile-images:
	XML.pushTag("GAME");
	XML.pushTag("MAP");
	XML.pushTag("TILES");
	XML.pushTag("DATA");
    
	for(int i = 0; i < tileCountX * tileCountY; i++) {
		string tempFileName = XML.getValue("TILE:PATH", "error.png", i);
        
		if(addImage(tempFileName, tempFileName, TILE))
			cout << "Added " << tempFileName << " to tile-images" << endl;
	}
    
	XML.popTag(); // DATA
	XML.popTag(); // TILES
	XML.popTag(); // MAP
	XML.popTag(); // GAME
}

ofImage* AssetManager::getImage(string key, int type) {
	//if we can't find key, we return a pointer to the first map-element
	//so the game doesn't crash but you know somehting's wrong
	switch(type) {
	case CHARACTER: {
		map<string, ofImage*>::iterator it = players.find(key);
		if(it != players.end())
			return it->second;
		else
			return players.begin()->second;
		}
		break;
	case TILE: {
		map<string, ofImage*>::iterator it = tiles.find(key);
		if(it != tiles.end())
			return it->second;
		else
			return tiles.begin()->second;
		}
		break;
	}
}
/*
ofSoundPlayer* AssetManager::getSound(string key) {
	return sounds.find(key)->second;
}
 */

void AssetManager::reset(string settingsFile, string mapFile) {
	releaseAssets();
	setup(settingsFile, mapFile);
}

void AssetManager::releaseAssets() {
	printf("releasing tiles\n");
	tiles.clear();
	printf("releasing players\n");
	players.clear();
	//printf("releasing sounds\n\n");
	//sounds.clear();
}

bool AssetManager::addImage(string key, string filename, int type) {
	pair<map<string, ofImage*>::iterator, bool> check;

	// load a new ofImage:
	ofImage* tempImage = new ofImage();
	if(!tempImage->loadImage(filename)) {
		return false;
	}

	// insert it into the container:
	switch(type) {
	case CHARACTER:
		check = players.insert(pair<string, ofImage*>(key, tempImage));
		break;
	case TILE:
		check = tiles.insert(pair<string, ofImage*>(key, tempImage));
		break;
	}

	if(check.second == true)
		return true;
	else
		return false;
}
/*
bool AssetManager::addSound(string key, string filename) {
	if(key != "") {
		pair<map<string, ofSoundPlayer*>::iterator, bool> check;

		// load a new ofSoundPlayer:
		ofSoundPlayer* tempSound = new ofSoundPlayer();
		tempSound->loadSound(filename);

		if(!tempSound->isLoaded()) {
			return false;
		}

		// insert it into the container:
		check = sounds.insert(pair<string, ofSoundPlayer*>(key, tempSound));

		if(check.second == true) {
			return true;
		}
		else {
			return false;
		}
	}
	else
		return false;
}
 */
