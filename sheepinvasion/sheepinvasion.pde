Map map;
// Position of player center in level coordinates
float playerX, playerY;
// Velocity of player

// left / top border of the screen in map coordinates
float screenLeftX, screenTopY;

//integer für schleifen
int i, j;

//timer für schüsse und gegner
float shotTimer, proShotTimer, enemyTimer;

// Die Arrayliste mit den Gegnern und den Schüssen
ArrayList<Shot> shots = new ArrayList<Shot>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();

//minim Import
//import ddf.minim.*;
//Minim minim;
// AudioPlayer player;
// AudioSnippet shot,proshot,hit,dead,explosion,moneytower;

//Money
float money = 40;

//Vektoren
PShape towerBasic,towerMoney, towerPro, enemyBasic, enemyEvil;

//Pixel
PImage tileB, tileG, tileS, tileT, tileP, tileM;

//Levelvariable um die Karten zu Kontrollieren
int score,lvl;

//Schwierigkeit
float difficulty = 0;

float time;
int GAMEWAIT=0, GAMERUNNING=1, GAMEOVER=2, GAMEWON=3, TowerBuy=4, MoneyTowerBuy=5, ProTowerBuy=6, TUTORIAL=7;
int gameState;

PImage backgroundImg;

float aspectRatio=9/7, scaleFactor;

float tileSize;

void setup() {
  //Lade Spielmusik
  /*minim = new Minim (this);
  //Lade Spielmusik (später loopen und beenden lassen)
  player = minim.loadFile ("sounds/soundtrack.wav");
  shot = minim.loadSnippet ("sounds/shot.wav");
  proshot = minim.loadSnippet ("sounds/proshot.wav");
  hit = minim.loadSnippet ("sounds/hit.wav");
  dead = minim.loadSnippet ("sounds/dead.wav");
  explosion = minim.loadSnippet ("sounds/explosion.wav");
  moneytower = minim.loadSnippet ("sounds/moneytower.wav");
  player.play ();
  player.loop ();*/
  size(window.innerWidth, window.innerHeight);

  if(window.innerWidth/window.innerHeight > aspectRatio) {
  	scaleFactor = window.innerHeight/700;
  }
  else {
  	scaleFactor = window.innerWidth/900;
  }

  tileSize = 100*scaleFactor;

  restart(1);
  frameRate(60);

  	tileB = loadImage("images/tiles/B.png");
	tileG = loadImage("images/tiles/G.png");
	tileS = loadImage("images/tiles/S.png");
	tileT = loadImage("images/tiles/T.png");
	tileP = loadImage("images/tiles/P.png");
	tileM = loadImage("images/tiles/M.png");

  shapeMode(CENTER);
  towerBasic = loadShape("images/towerBasic.svg");
  towerMoney = loadShape("images/towerMoney.svg");
  towerPro = loadShape("images/towerPro.svg");

  enemyBasic = loadShape("images/enemyBasic.svg");
  enemyEvil = loadShape("images/enemyEvil.svg");
 }
// Die Karte wird neu gezeichnet und alle Spielfiguren und Schüsse werden aus dem Array entfernt.
// Je nach Wert von "lvl" wird eine andere .map Datei geladen und die Difficulty verändert.
void restart (int lvl) {
	map = new Map(lvl);
	time=0;
	for (int i = 0; i < enemies.size(); ++i) {
		enemies.remove(i);
		i--;
	}
	for (int i = 0; i < shots.size(); ++i) {
		shots.remove(i);
		i--;
	}
	if (lvl == 1) {
		score = 0;
		difficulty = 19;
		gameState = TUTORIAL;
		money = 40;
	}
	if (lvl == 2) {
		difficulty = 5;
		score = 11;
		gameState = GAMEWAIT;
		money = 40;
	}
	if (lvl == 3) {
		difficulty = 2;
		score = 31;
		gameState = GAMEWAIT;
		money = 60;
	}
}
// Es wird überprüft wie der Punktestand ist. Werden bestimmte Punkte erreicht, wird das Spiel mit einer neuen Karte neugestartet.
void levelSwitch() {
	if (score==50) {
		gameState = GAMEWON;
	}
	else if (score==30) {
		restart(3);
	}
	else if (score==10) {
		restart(2);
	}

	if (score<=10) {
		textSize(24);
		textAlign(LEFT);
		fill(#ecf0f1);
		text("Level 1", width-130,50);
	}
	else if (score>=10) {
		textSize(24);
		textAlign(LEFT);
		fill(#ecf0f1);
		text("Level 2", width-130,50);
	}
	else if (score>=30) {
		textSize(24);
		textAlign(LEFT);
		fill(#ecf0f1);
		text("Level 3", width-130,50);
	}
}

void drawMap() {
  // The left border of the screen is at screenLeftX in map coordinates
  // so we draw the left border of the map at -screenLeftX in screen coordinates
  // Same for screenTopY.
  map.draw();
}

// Malt die Buttons für die Tower und ändert auf Klick den GameState
void drawButton_Tower () {
	textSize(18);
	textAlign(CENTER);
	if (mouseX > 25 && mouseX < 25+200 && mouseY > height-100 && mouseY < height-100+50){
		fill(#9b59b6);
		rect(25, height-100, 200, 50);

		if (mousePressed==true){
			gameState = TowerBuy;
		}
	}
	else{
		fill(#f1c40f);
		rect(25, height-100, 200, 50);
	}
	fill(#ffffff);
	text("Schussturm (15)", 200/2+25,height-100+33);
}

void drawButton_moneyTower () {
	textSize(18);
	textAlign(CENTER);
	if (mouseX > 280 && mouseX < 280+200 && mouseY > height-100 && mouseY < height-100+50){
		fill(#9b59b6);
		rect(280, height-100, 200, 50);

		if (mousePressed==true){
			gameState = MoneyTowerBuy;
		}
	}
	else{
		fill(#f1c40f);
		rect(280, height-100, 200, 50);
	}
	fill(#ffffff);
	text("Geldturm (25)", 200/2+280,height-100+33);
}

void drawButton_proTower () {
	textSize(18);
	textAlign(CENTER);
	if (mouseX > 525 && mouseX < 525+200 && mouseY > height-100 && mouseY < height-100+60){
		fill(#9b59b6);
		rect(525, height-100, 250, 50);

		if (mousePressed==true){
			gameState = ProTowerBuy;
		}
	}
	else{
		fill(#f1c40f);
		rect(525, height-100, 250, 50);
	}
	fill(#ffffff);
	text("Schussturm Upgrade (50)", 200/2+545,height-100+33);
}

// Pausiert das Spiel und lässt einen Tower auf das Feld bauen.
void mousePressed() {
	if (gameState==TowerBuy && map.atPixel(mouseX, mouseY) == "G" || gameState==TowerBuy && map.atPixel(mouseX, mouseY) == "M") {
		map.setPixel(mouseX, mouseY, "T");
		money=money-15;
		gameState=GAMERUNNING;
	}

      //Pro Tower als Upgrade des normalen Towers
      if (gameState==ProTowerBuy && map.atPixel(mouseX, mouseY) == "T") {
      	map.setPixel(mouseX, mouseY, "P");
      	money=money-50;
      	gameState=GAMERUNNING;
      }
      if (gameState==MoneyTowerBuy && map.atPixel(mouseX, mouseY) == "G" || gameState==MoneyTowerBuy && map.atPixel(mouseX, mouseY) == "P" || gameState==MoneyTowerBuy && map.atPixel(mouseX, mouseY) == "T") {
      	map.setPixel(mouseX, mouseY, "M");
      	money=money-25;
      	// moneytower.setGain(-15);
       //  moneytower.play(0);
      	gameState=GAMERUNNING;
      }

  }

// Überprüft wie viel Geld da ist und malt dann einen Button für mögliche Investitionen
void checkMoney(){
	textSize(24);
	textAlign(LEFT);
	fill(#ecf0f1);
	text("Du hast "+int(money)+" Münzen", 25,50);
	if (money>=15){
		drawButton_Tower();
	}
	if (money>=25){
		drawButton_moneyTower();
	}
	if (money>=50){
		drawButton_proTower();
	}

	textSize(24);
	textAlign(LEFT);
	fill(#ecf0f1);
	text("Score: "+score, width-300,50);
}

void drawText() {
	textAlign(CENTER, CENTER);
	fill(0, 255, 0);

	if (gameState==TUTORIAL) {
		fill(0, 0, 0, 180);
		rect(0,0,width, height);
		//background(0, 0, 0, 0.5);

		fill(0, 255, 0);
		textSize(20);
		text ("Geldtürme generieren Münzen und sind nötig, um weitere Türme bauen zu können", width/2, height/2-180);
		shape(towerMoney,width/2-100,height/2-180+70,50,50);
		shape(towerMoney,width/2,height/2-180+70,50,50);
		shape(towerMoney,width/2+100,height/2-180+70,50,50);

		text ("Baue Schusstürme um die Schafe aufzuhalten", width/2, height/2);
		shape(towerBasic,width/2-180,height/2+70,50,75);
		shape(towerPro,width/2-100,height/2+70,50,75);
		shape(enemyBasic,width/2+180,height/2+70,112,75);

		text ("Wähle einen Turm um anzufangen", width/2, height/2+180);
	}
	else if (gameState==GAMEWAIT) {textSize(40); text("Wähle einen Turm um anzufangen", width/2, height/2);}

	else if (gameState==GAMEOVER) {textSize(40); text("Game Over - Drücke R", width/2, height/2);}
	else if (gameState==GAMEWON) {textSize(40); text("Gewonnen in "+ round(time) + " Sekunden - Drücke R", width/2, height/2);}
}

// Malt die Tower für ein besseres Verständnis während des Kaufvorgangs
void towerDraw(float towerX1,float towerY1){
	shape(towerBasic,towerX1,towerY1,50*scaleFactor,75*scaleFactor);
}

void moneytowerDraw(float moneytowerX1,float moneytowerY1){
	shape(towerMoney,moneytowerX1,moneytowerY1,50*scaleFactor,50*scaleFactor);
}

void protowerDraw(float protowerX1,float protowerY1){
	shape(towerPro,protowerX1,protowerY1,50*scaleFactor,75*scaleFactor);
}
// Es wird überprüft wo ein Geldturm auf dem Feld steht. Existiert ein Turm, wird Geld generiert.
void generateMoney() {
	for (i = 0; i < map.w; i++) {
		for (j = 0; j < map.h; j++) {
			if (map.at(i,j) == "M"){
				money+=1/frameRate;
			}
		}
	}
}

class Map {
	int w, h;
	//float tileSize;
	char[][] mapArray, level1, level2, level3;
	
	Map (int lvl) {
		w = 9;
		h = 7;

		//float tileSize = 100*scaleFactor;
		//Level
		level1 = {
				{"B","B","B","B","B","B","B","B","B"},
				{"B","B","B","B","B","B","B","B","B"},
				{"B","B","B","B","B","B","B","B","B"},
				{"G","G","G","G","G","G","G","G","S"},
				{"B","B","B","B","B","B","B","B","B"},
				{"B","B","B","B","B","B","B","B","B"},
				{"B","B","B","B","B","B","B","B","B"}
			};
		level2 = {
				{"B","B","B","B","B","B","B","B","B"},
				{"B","B","B","B","B","B","B","B","B"},
				{"G","G","G","G","G","G","G","G","S"},
				{"G","G","G","G","G","G","G","G","S"},
				{"G","G","G","G","G","G","G","G","S"},
				{"B","B","B","B","B","B","B","B","B"},
				{"B","B","B","B","B","B","B","B","B"}
			};
		level3 = {
				{"B","B","B","B","B","B","B","B","B"},
				{"G","G","G","G","G","G","G","G","S"},
				{"G","G","G","G","G","G","G","G","S"},
				{"G","G","G","G","G","G","G","G","S"},
				{"G","G","G","G","G","G","G","G","S"},
				{"G","G","G","G","G","G","G","G","S"},
				{"B","B","B","B","B","B","B","B","B"}
			};

		if (lvl==1) {
			mapArray = level1;
		}

		else if (lvl==2) {
			mapArray = level2;
		}

		else if (lvl==3) {
			mapArray = level3;
		}
	}

	char at(int x,int y){
		if (x < w && y < h) {
			return mapArray[y][x];
		}
		else {
			return "B"; //doesn’t fix crash either
		}
	}
	char atPixel(float x, float y){
		if (x <= width && y <= height) {
			return mapArray[int(y/tileSize)][int(x/tileSize)];
		}
		else {
			return "B"; //more like a hack but works / edit: only fixes crash in processing, not processing.js
		}
	}
	void setPixel(int x, int y, char tile) {
		mapArray[int(float(y)/tileSize)][int(float(x)/tileSize)] = tile;
	}
	void draw() { //could be coded much better but don’t know how to use string for loading PShape
		for(int i=0; i<w; i++) {
			for(int j=0; j<h; j++) {
				if (at(i,j) == "B") {
					image(tileB,i*tileSize,j*tileSize,tileSize,tileSize);
				}
				else if (at(i,j) == "G") {
					image(tileG,i*tileSize,j*tileSize,tileSize,tileSize);
				}
				else if (at(i,j) == "S") {
					image(tileS,i*tileSize,j*tileSize,tileSize,tileSize);
				}
				else if (at(i,j) == "T") {
					image(tileT,i*tileSize,j*tileSize,tileSize,tileSize);
				}
				else if (at(i,j) == "P") {
					image(tileP,i*tileSize,j*tileSize,tileSize,tileSize);
				}
				else if (at(i,j) == "M") {
					image(tileM,i*tileSize,j*tileSize,tileSize,tileSize);
				}
			}
		}
	}
};

// Der Schuss  wird hier berechnet und gemalt.
class Shot {
	float x,y,eX,eY;
	int r;
	color c;

	Shot (float _x, float j, int _r, color _c) {
		x=_x;
		y=((j+1)*100-65)*scaleFactor;
		r=_r;
		c=_c;
	}
// Der Schuss wird über das feld Bewegt.
	void move() {
		x+=300*scaleFactor/frameRate;
	}
// Es wird geprüft ob der Schuss das Spielfeld verlassen hat.
	boolean fail() {
		if (x>=width+5) {
			return true;
		}
		else {
			return false;
		}
	}

	void run() {
		noStroke();
		fill (c);
		ellipse(x,y,r,r);
	}
};
// Es wird überprüft wo ein Turm auf dem Feld steht und nach den Regeln des Timers ein neuer Schuss generiert.
void addShots() {
  if (shotTimer >=1) {
    for (i = 0; i < map.w; i++) {
      for (j = 0; j < map.h; j++) {
        if (map.at(i,j) == "T"){
          shots.add(
            new Shot(((i+1)*100-28)*scaleFactor,j, 3*scaleFactor, #2aff00)
            );
          // shot.setGain(-15);
          // shot.play(0);
        }
      }
    }
    shotTimer = 0;
  }
}

void addProShots() {
	if (proShotTimer >=0.4) {
		for (i = 0; i < map.w; i++) {
			for (j = 0; j < map.h; j++) {
				if (map.at(i,j) == "P"){
					shots.add(
						new Shot(((i+1)*100-24)*scaleFactor,j, 4*scaleFactor, #00e0ff)
						);
					// proshot.setGain(-25);
					// proshot.play(0);
				}
			}
		}
		proShotTimer = 0;
	}
}

void moveShots() {
	for (int i = 0; i < shots.size(); ++i) {
		shots.get(i).move();
    	//removeShots
    	if (shots.get(i).fail()) {
    		shots.remove(i);
    		i--;
    	}
	}
}
// Der  Gegner wird hier berechnet und gespawnt
class Enemy {
  float x,y,yWiggle,health;
  int typ;
  float speed=(random(20,25))*scaleFactor;
  float time=random(0,10); //time startet an zufälligem Punkt damit nicht alle synchron laufen

  Enemy (float _x, float j, int _typ) {
    x=_x;
    y=((j+1)*100-50)*scaleFactor;
    yWiggle=y;
    typ=_typ;

    if (typ == 1) {
      health = 60;
    }
    else if (typ ==2){
      health = 150;
    }

  }

  void move() {
    x-=speed/frameRate;
    time+=1/frameRate;
    yWiggle+=0.3*sin(time*15)*scaleFactor;

//Der Gegner wird verwundet wenn der Schuss trifft. Der Schuss wird dann aus dem Array entfernt.
    for (int i = 0; i < shots.size(); ++i) {
      if (shots.get(i).x >= x-(60*scaleFactor) && shots.get(i).x <= x+(60*scaleFactor) && shots.get(i).y >= y-(20*scaleFactor) && shots.get(i).y <= y+(20*scaleFactor)) {
        health -= 3;
        shots.remove(i);
        i--;
        // hit.setGain(-15);
        // hit.play(0);
      }
    }
  }
// Prüft ob die Gesundheit des Gegners bei 0 ist. Gibt true zurück, wenn dem so ist
  boolean dead() {
    if (health <= 0) {
      return true;
    }
    else {
      return false;
    }
  }
//Lässt die Gegner über das Feld bewegen und leicht wackeln (Schritte)
  void run() {
    if (typ ==1) {
    noStroke();
    shape(enemyBasic,x,yWiggle,112*scaleFactor,75*scaleFactor);
    fill(0);
    rect(x-(112/2*scaleFactor),y+(40*scaleFactor),102*scaleFactor,5*scaleFactor);
    fill(0,180,0);
    rect(x-(112/2*scaleFactor)+1*scaleFactor,y+41*scaleFactor,health/60*100*scaleFactor,3*scaleFactor);
    }

    if (typ ==2) {
    noStroke();
    shape(enemyEvil,x,yWiggle,112*scaleFactor,75*scaleFactor);
    fill(0);
    rect(x-(112/2*scaleFactor),y+(40*scaleFactor),102*scaleFactor,7*scaleFactor);
    fill(0,250,0);
    rect(x-(112/2*scaleFactor)+1*scaleFactor,y+41*scaleFactor,health/150*100*scaleFactor,5*scaleFactor);
    }
// Wenn einer der Gegner auf der linken Seite des Spielfeldes ankommt, ist das Spiel verloren
    if (x<=0) {
    	gameState = GAMEOVER;
    }
  }
};
// Lässt Gegner auf ihrem Startfeld erscheinen. Es wird für jedes Feld einzelnd ausgewürfelt und ist von "Difficulty" beeinflussbar
void spawnEnemies() {
	if (enemyTimer >= 5) {
		for (i = 0; i < map.w; i++) {
			for (j = 0; j < map.h; j++) {
				if (map.at(i,j) == "S" && random(0,100)<=difficulty){
					if(random(20,100)>=difficulty)
						enemies.add(
							new Enemy(((i+1)*100+50)*scaleFactor,j, 1)
							);
					else {
						enemies.add(
							new Enemy(((i+1)*100+50)*scaleFactor,j, 2)
							);
					}
				}
			}
		}
		enemyTimer = 0;
		difficulty+=2;
	}
}

void moveEnemies() {
	for (int i = 0; i < enemies.size(); ++i) {
		enemies.get(i).move();

      // Wenn der Gegner ein Feld mit einem Turm erreicht, wird das Feld ausgetauscht
      if (map.atPixel(enemies.get(i).x, enemies.get(i).y)=="T" || map.atPixel(enemies.get(i).x, enemies.get(i).y)=="M" || map.atPixel(enemies.get(i).x, enemies.get(i).y)=="P"){
      	map.setPixel(int(enemies.get(i).x),int(enemies.get(i).y), "G");
      	// explosion.setGain(-15);
      	// explosion.play(0);
      }

      //Hier wird geprüft ob der Gegner tot ist (siehe Boolean in der Klasse). Starb der Gegner werden der Geld- und Punktestand höher gesetzt.
      if (enemies.get(i).dead()) {
      	enemies.remove(i);
      	i--;
      	score++;
      	money+=5;
      	// dead.setGain(-15);
      	// dead.play(0);
      }
  }
}

void draw() {
  background(128);
  drawMap();
  playerX = mouseX;
  playerY = mouseY;

  for (int i = 0; i < shots.size(); ++i) {
    shots.get(i).run();
  }
  for (int i = 0; i < enemies.size(); ++i) {
    enemies.get(i).run();
  }

  drawText();
  checkMoney();
  levelSwitch();

  if (gameState==TowerBuy) {
  	textSize(18);
  	textAlign(CENTER);
  	fill(#ffffff);
  	rect(25, height-100, 200, 50);
  	fill(#9b59b6);
  	text("Abbruch mit a", 200/2+25,height-100+33);
  	towerDraw(mouseX,mouseY);
  	if (keyPressed && key=='a') {
  		gameState = GAMERUNNING;
  	}
  }

  if (gameState==MoneyTowerBuy) {
  	textSize(18);
  	textAlign(CENTER);
  	fill(#ffffff);
  	rect(280, height-100, 200, 50);
  	fill(#f1c40f);
  	text("Abbruch mit a", 200/2+280,height-100+33);
  	moneytowerDraw(mouseX,mouseY);
  	if (keyPressed && key=='a') {
  		gameState = GAMERUNNING;
  	}
  }

  if (gameState==ProTowerBuy) {
  	textSize(18);
  	textAlign(CENTER);
  	fill(#ffffff);
  	rect(525, height-100, 250, 50);
  	fill(#9b59b6);
  	text("Abbruch mit a", 200/2+545,height-100+33);
  	protowerDraw(mouseX,mouseY);
  	if (keyPressed && key=='a') {
  		gameState = GAMERUNNING;
  	}
  }

  if (gameState==GAMERUNNING) {
    //verschiedene Timer werden hochgezählt
    time+=1/frameRate;
    shotTimer+=1/frameRate;
    proShotTimer+=1/frameRate;
    enemyTimer+=1/frameRate;

    moveEnemies();
    addShots();
    addProShots();
    spawnEnemies();
    generateMoney();
    moveShots();
  }

  else if (keyPressed && key=='r') {
    if (gameState==GAMEWAIT) gameState=GAMERUNNING;
    else if (gameState==GAMEOVER || gameState==GAMEWON) restart(1);
  }

}
