Map map;
// Position of player center in level coordinates
float playerX, playerY;
// Velocity of player
float vx, vy;
// Speed at which the player moves
float speed = 150;
// The player is a circle and this is its radius
float playerR = 10;
// Position of the goal center
// Will be set by restart
float goalX=0, goalY=0;
// Whether to illustrate special functions
boolean showSpecialFunctions=false;

// left / top border of the screen in map coordinates
float screenLeftX, screenTopY;

//integer für schleifen
int i, j;

//objects
ArrayList<Shot> shots = new ArrayList<Shot>();
Shot myShot;

//minim Import
import ddf.minim.*;
Minim minim;
AudioPlayer player;

//Money
int money = 0;
//Vektoren
PShape towerBasic,towerMoney;

float time;
int GAMEWAIT=0, GAMERUNNING=1, GAMEOVER=2, GAMEWON=3, TowerBuy=4, MoneyTowerBuy=5;
int gameState;

PImage backgroundImg;

void setup() {
  //Lade Spielmusik
  minim = new Minim (this);
  //Lade Spielmusik (später loopen und beenden lassen
  player = minim.loadFile ("music/soundtrack.wav");
  player.play ();
  player.loop ();
  frame.setResizable(true);
  size( 900, 700 );
  restart();
  frameRate(24);
  towerBasic = loadShape("images/towerBasic.svg");
  towerMoney = loadShape("images/towerMoney.svg");
}

void restart () {
  map = new Map( "levelone.map");
  /*for ( int x = 0; x < map.w; ++x ) {
    for ( int y = 0; y < map.h; ++y ) {
      if ( map.at(x, y) == 'S' ) {
        playerX = map.centerXOfTile (x);
        playerY = map.centerYOfTile (y);
        map.set(x, y, 'F');
      }
      if ( map.at(x, y) == 'E' ) {
        goalX = map.centerXOfTile (x);
        goalY = map.centerYOfTile (y);
      }
    }
  }*/
  time=0;
  vx = 0;
  vy = 0;
  gameState = GAMEWAIT;
}

void keyPressed() {
  if ( keyCode == UP && vy == 0 ) {
    vy = -speed;
    vx = 0;
  }
  else if ( keyCode == DOWN && vy == 0 ) {
    vy = speed;
    vx = 0;
  }
  else if ( keyCode == LEFT && vx == 0 ) {
    vx = -speed;
    vy = 0;
  }
  else if ( keyCode == RIGHT && vx == 0 ) {
    vx = speed;
    vy = 0;
  }
  else if ( keyCode == 'S' ) showSpecialFunctions = !showSpecialFunctions;
}


void updatePlayer() {
  // update player
  float nextX = playerX + vx/frameRate,
  nextY = playerY + vy/frameRate;
  if ( map.testTileInRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "W_" ) ) {
    vx = -vx;
    vy = -vy;
    nextX = playerX;
    nextY = playerY;
  }
  else if ( map.testTileFullyInsideRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "H" ) ) {
    gameState=GAMEOVER;
  }

   else if ( map.testTileFullyInsideRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "P" ) ) {
     gameState=GAMEOVER;
  }

  else if ( map.testTileFullyInsideRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "E" ) ) {
    gameState=GAMEWON;
  }

  playerX = nextX;
  playerY = nextY;
}

// Maps input to an output, such that
//     - input0 is mapped to output0
//     - a increasing input by 1 increases output by factor
float map (float input, float input0, float output0, float factor) {
  return factor*(input-input0)+output0;
}

void drawBackground() {
  // Explanation to the computation of x and y:
  // If screenLeftX increases by 1, i.e. the main level moves 1 to the left on screen,
  // we want the background map to move 0.5 to the left, i.e. x decrease by 0.5
  // Further, imagine the center of the screen (width/2) corresponds to the center of the level
  // (map.widthPixel), i.e. screenLeftX=map.widthPixel()/2-width/2. Then we want
  // the center of the background image (backgroundImg.width/2) also correspond to the screen
  // center (width/2), i.e. x=-backgroundImg.width/2+width/2.
  float x = map (screenLeftX, map.widthPixel()/2-width/2, -backgroundImg.width/2+width/2, -0.5);
  float y = map (screenTopY, map.heightPixel()/2-height/2, -backgroundImg.height/2+height/2, -0.5);
  image (backgroundImg, x, y);
}


void drawMap() {
  // The left border of the screen is at screenLeftX in map coordinates
  // so we draw the left border of the map at -screenLeftX in screen coordinates
  // Same for screenTopY.
  map.draw( -screenLeftX, -screenTopY );
}


void drawPlayer() {
  // draw player
  noStroke();
  fill(0, 255, 255);
  ellipseMode(CENTER);
  ellipse( playerX - screenLeftX, playerY - screenTopY, 2*playerR, 2*playerR );

  // understanding this is optional, skip at first sight
  if (showSpecialFunctions) {
    // draw a line to the next hole
    Map.TileReference nextHole = map.findClosestTileInRect (playerX, playerY, 200, 200, "H");
    stroke(255, 0, 255);
    if (nextHole!=null) line (playerX-screenLeftX, playerY-screenTopY,
    nextHole.centerX-screenLeftX, nextHole.centerY-screenTopY);

    // draw line of sight to goal (until next wall) (understanding this is optional)
    stroke(0, 255, 255);
    Map.TileReference nextWall = map.findTileOnLine (playerX, playerY, goalX, goalY, "W");
    if (nextWall!=null)
      line (playerX-screenLeftX, playerY-screenTopY, nextWall.xPixel-screenLeftX, nextWall.yPixel-screenTopY);
    else
      line (playerX-screenLeftX, playerY-screenTopY, goalX-screenLeftX, goalY-screenTopY);
  }
}

void drawButton_Tower () {
  if (mouseX > 25 && mouseX < 25+200 && mouseY > 500 && mouseY < 500+50){
    fill(#9b59b6);
    rect(25, 700, 200, 50);

    if (mousePressed==true){
      gameState = TowerBuy;
      fill(#ffffff);
      rect(25, 500, 200, 50);
    }
  }
  else{
    fill(#f1c40f);
    rect(25, 500, 200, 50);
  }
  fill(#ffffff);
  textSize(18);
  textAlign(CENTER);
  text("SchussTurm (15)", 200/2+25,500+33);
}

void drawButton_moneyTower () {
  if (mouseX > 280 && mouseX < 280+200 && mouseY > 500 && mouseY < 500+50){
    fill(#9b59b6);
    rect(280, 700, 200, 50);

    if (mousePressed==true){
      gameState = MoneyTowerBuy;
      fill(#ffffff);
      rect(280, 500, 200, 50);
    }
  }
  else{
    fill(#f1c40f);
    rect(280, 500, 200, 50);
  }
  fill(#ffffff);
  textSize(18);
  textAlign(CENTER);
  text("Geldturm (25)", 200/2+280,500+33);
}

void mousePressed() {
      if (gameState==TowerBuy && map.atPixel(mouseX, mouseY) == 'G') {
       map.setPixel(mouseX, mouseY, 'T');
       money=money-15;
       gameState=GAMERUNNING;
      }
      if (gameState==MoneyTowerBuy && map.atPixel(mouseX, mouseY) == 'G') {
       map.setPixel(mouseX, mouseY, 'M');
       money=money-25;
       gameState=GAMERUNNING;
      }

}

void checkMoney(){
  textSize(24);
  textAlign(LEFT);
  fill(#ecf0f1);
  text("Du hast "+money+" Münzen", 25,50);
  if (money>=15){
    drawButton_Tower();
  }
  if (money>=25){
    drawButton_moneyTower();
  }
}

void drawText() {
  textAlign(CENTER, CENTER);
  fill(0, 255, 0);
  textSize(40);
  if (gameState==GAMEWAIT) text ("press space to start", width/2, height/2);
  else if (gameState==GAMEOVER) text ("game over", width/2, height/2);
  else if (gameState==GAMEWON) text ("won in "+ round(time) + " seconds", width/2, height/2);
}

void towerDraw(float towerX1,float towerY1){
  shape(towerBasic,towerX1,towerY1,50,75);
}

void moneytowerDraw(float moneytowerX1,float moneytowerY){
  shape(towerMoney,moneytowerX1,moneytowerY,50,50);
  }

class Shot {
  float x;
  float y;

  Shot (float _x, float _y) {
    x=_x;
    y=_y;
  }

  void move() {
    x+=300/frameRate;
  }

  void run() {
    //x+=300/frameRate;
    ellipse(x,y,3,3);
  }
}

void draw() {
  //screenLeftX = playerX - width/2;
  //screenTopY  = (map.heightPixel() - height)/2;

  //drawBackground();
  background(128);
  drawMap();
  playerX = mouseX;
  playerY = mouseY;
  checkMoney();
  drawPlayer();
  drawText();

   if (gameState==TowerBuy) {
    towerDraw(mouseX,mouseY);
  }

   if (gameState==MoneyTowerBuy) {
    moneytowerDraw(mouseX,mouseY);
  }

    if (gameState==GAMERUNNING) {
    //updatePlayer();
    time+=1/frameRate;
    money=money+1;

    //schleife die prüft wo türme sind, vorerst ellipsen als platzhalter
  for (i = 0; i < 8; i++) {
    for (j = 0; j < 4; j++) {
      if (map.at(i,j) == 'T'){ //&&check ob wert noch nicht in array ist
        //myShot = new Shot((i+1)*100-50,(j+1)*100-50);
        shots.add(
          new Shot((i+1)*100-50,(j+1)*100-50)
      );
        //myShot.run();
      }
    }
  }

  }
  else if (keyPressed && key==' ') {
    if (gameState==GAMEWAIT) gameState=GAMERUNNING;
    else if (gameState==GAMEOVER || gameState==GAMEWON) restart();
  }
    for (int i = 0; i < shots.size(); ++i) {
    shots.get(i).move();
    shots.get(i).run();


  }

}
