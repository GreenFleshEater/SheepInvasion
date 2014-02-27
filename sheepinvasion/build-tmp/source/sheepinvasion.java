import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sheepinvasion extends PApplet {

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

float time;
int GAMEWAIT=0, GAMERUNNING=1, GAMEOVER=2, GAMEWON=3;
int gameState;

PImage backgroundImg;

public void setup() {
  size( 500, 500 );
  backgroundImg = loadImage ("images/fire.jpg");
  restart();
  frameRate(24);
}

public void restart () {
  map = new Map( "levelone.map");
  for ( int x = 0; x < map.w; ++x ) {
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
  }
  time=0;
  vx = 0;
  vy = 0;
  gameState = GAMEWAIT;
}

public void keyPressed() {
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


public void updatePlayer() {
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
public float map (float input, float input0, float output0, float factor) {
  return factor*(input-input0)+output0;
}

public void drawBackground() {
  // Explanation to the computation of x and y:
  // If screenLeftX increases by 1, i.e. the main level moves 1 to the left on screen,
  // we want the background map to move 0.5 to the left, i.e. x decrease by 0.5
  // Further, imagine the center of the screen (width/2) corresponds to the center of the level
  // (map.widthPixel), i.e. screenLeftX=map.widthPixel()/2-width/2. Then we want
  // the center of the background image (backgroundImg.width/2) also correspond to the screen
  // center (width/2), i.e. x=-backgroundImg.width/2+width/2.
  float x = map (screenLeftX, map.widthPixel()/2-width/2, -backgroundImg.width/2+width/2, -0.5f);
  float y = map (screenTopY, map.heightPixel()/2-height/2, -backgroundImg.height/2+height/2, -0.5f);
  image (backgroundImg, x, y);
}


public void drawMap() {   
  // The left border of the screen is at screenLeftX in map coordinates
  // so we draw the left border of the map at -screenLeftX in screen coordinates
  // Same for screenTopY.
  map.draw( -screenLeftX, -screenTopY );
}


public void drawPlayer() {
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


public void drawText() { 
  textAlign(CENTER, CENTER);
  fill(0, 255, 0);  
  textSize(40);  
  if (gameState==GAMEWAIT) text ("press space to start", width/2, height/2);
  else if (gameState==GAMEOVER) text ("game over", width/2, height/2);
  else if (gameState==GAMEWON) text ("won in "+ round(time) + " seconds", width/2, height/2);
}


public void draw() {
  if (gameState==GAMERUNNING) {
    updatePlayer();
    time+=1/frameRate;
  }
  else if (keyPressed && key==' ') {
    if (gameState==GAMEWAIT) gameState=GAMERUNNING;
    else if (gameState==GAMEOVER || gameState==GAMEWON) restart();
  }
  screenLeftX = playerX - width/2;
  screenTopY  = (map.heightPixel() - height)/2;

  drawBackground();
  drawMap();
  drawPlayer();
  drawText();
}




class Map
{  
  int mode = CORNER;


  // Constructor: tmptileSize is the width/height of one tile in pixel
  Map( int tmptileSize ) {
    tileSize = tmptileSize;
    images = new PImage[26];
  }

  // Constructor: Loads a map file
  Map( String mapFile ) {
    images = new PImage[26];
    loadFile( mapFile );
  }

  //! Sets the mode in which coordinates are specified, supported is CORNER, CENTER, CORNERS
  public void mode (int tmpMode) { 
    mode=tmpMode;
  }


  public int widthPixel() {
    return w * tileSize;
  }

  public int heightPixel() {
    return h * tileSize;
  }

  // Left border (pixel) of the tile at tile position x
  public int leftOfTile(int x) {
    return x * tileSize;
  }

  // Right border (pixel) of the tile at tile position x
  public int rightOfTile(int x) {
    return (x+1) * tileSize-1;
  }

  // Top border (pixel) of the tile at tile position y
  public int topOfTile(int y) {
    return y * tileSize;
  }

  // Bottom border (pixel) of the tile at tile position y
  public int bottomOfTile(int y) {
    return (y+1) * tileSize-1;
  }

  //! Center of the tile at tile position x
  public int centerXOfTile (int x) {
    return x*tileSize+tileSize/2;
  }

  //! Center of the tile at tile position x
  public int centerYOfTile (int y) {
    return y*tileSize+tileSize/2;
  }

  // Returns the tile at tile position x,y. '_' for invalid positions (out of range)
  public char at( int x, int y ) {
    if ( x < 0 || y < 0 || x >= w || y >= h )
      return '_';
    else
      return map[y].charAt(x);
  }

  // Returns the tile at pixel position 'x,y', '_' for invalid
  public char atPixel (float x, float y) {
    return at (floor(x/tileSize), floor(y/tileSize));
  }

  // Sets the tile at tile position x,y
  // Coordinates below 0 are ignored, for coordinates
  // beyond the map border, the map is extended
  public void set (int x, int y, char ch) {
    if ( x < 0 || y < 0 ) return;
    extend (x+1, y+1);
    map[y] = replace (map[y], x, ch);
  }

  // Sets the tile at image position 'x,y' see set
  public void setPixel (int x, int y, char ch) {
    set (x/tileSize, y/tileSize, ch);
  }


  // Reference to a tile in the map  
  class TileReference {
    // Position in the map in tiles
    int x, y;
    // Position in the map in pixels
    // This position definitely belong to the tile (x,y)
    // where it is on the tile depents on the function returning this reference
    float xPixel, yPixel;
    // Type of the tile
    char tile;
    // Border of that tile in pixel
    int left, right, top, bottom;
    // Center of that tile in pixel
    int centerX, centerY;

    // Creates a reference to the tile at (x,y)
    // all other components are taken from the map
    TileReference (int tmpX, int tmpY) {
      x = tmpX;
      y = tmpY;
      setBorders();
      xPixel = centerX;
      yPixel = centerY;
    }

    // Computes tile, left, right, top, bottom, centerX, centerY from referenced tile
    public void setBorders() {
      tile = at(x, y);
      left = leftOfTile(x);
      right = rightOfTile(x);
      top = topOfTile(y);
      bottom = bottomOfTile(y);
      centerX =  centerXOfTile(x);
      centerY = centerYOfTile(y);
    }


    // Consider the line xPixel, yPixel towards goalX, goalY.
    // This line must start in tile x, y.
    // Then advanceTowards follows this line until it leaves x, y
    // updating xPixel,yPixel with the point where it leaves
    // and the rest with the tile it enters.
    public void advanceTowards (float goalX, float goalY)
    {
      float dX = goalX-xPixel;
      float dY = goalY-yPixel;
      // First try to go x until next tile
      float lambdaToNextX = Float.POSITIVE_INFINITY;
      if (dX>0) {
        float nextX = (x+1)*tileSize;
        lambdaToNextX = (nextX-xPixel)/dX;
      }   
      else if (dX<0) {
        float nextX = x*tileSize;
        lambdaToNextX = (nextX-xPixel)/dX;
      }
      // Then try to go y until next tile
      float lambdaToNextY = Float.POSITIVE_INFINITY;
      if (dY>0) {
        float nextY = (y+1)*tileSize;
        lambdaToNextY = (nextY-yPixel)/dY;
      }   
      else if (dY<0) {
        float nextY = y*tileSize;
        lambdaToNextY = (nextY-yPixel)/dY;
      }
      // Then choose which comes first x, y or goal
      if (lambdaToNextX<lambdaToNextY && lambdaToNextX<1) { // Go x
        xPixel += dX*lambdaToNextX;
        yPixel += dY*lambdaToNextX;
        if (dX>0) x++;
        else x--;
      }
      else if (lambdaToNextY<=lambdaToNextX && lambdaToNextY<1) { // Go y
        xPixel += dX*lambdaToNextY;
        yPixel += dY*lambdaToNextY;
        if (dY>0) y++;
        else y--;
      }
      else {// reached goal in same cell
        xPixel = goalX;
        yPixel = goalY;
      }
    }
  };
  
    // Returns a reference to a given pixel and its tile
    public TileReference newRefOfPixel (float pixelX, float pixelY) {
      TileReference ref = new TileReference (floor(pixelX/tileSize), floor(pixelY/tileSize));
      ref.xPixel = pixelX;
      ref.yPixel = pixelY;
      return ref;
    }


  // True if the rectangle given by x, y, w, h (partially) contains an element with a tile
  // from list. The meaning of x,y,w,h is governed by mode (CORNER, CENTER, CORNERS.
  public boolean testTileInRect( float x, float y, float w, float h, String list ) {
    if (mode==CENTER) {
      x-=w/2;
      y-=w/2;
    }
    if (mode==CORNERS) {
      w=w-x;
      h=h-y;
    }
    int startX = floor(x / tileSize), 
    startY = floor(y / tileSize), 
    endX   = floor((x+w) / tileSize), 
    endY   = floor((y+h) / tileSize);

    for ( int xx = startX; xx <= endX; ++xx )
    {
      for ( int yy = startY; yy <= endY; ++yy )
      {
        if ( list.indexOf( at(xx, yy) ) != -1 )
          return true;
      }
    }
    return false;
  }

  // Like testtileInRect(...) but returns a reference to the tile if one is found
  // and null else. The meaning of x,y,w,h is governed by mode (CORNER, CENTER, CORNERS.
  public TileReference findTileInRect( float x, float y, float w, float h, String list ) {
    if (mode==CENTER) {
      x-=w/2;
      y-=w/2;
    }
    if (mode==CORNERS) {
      w=w-x;
      h=h-y;
    }
    int startX = floor(x / tileSize), 
    startY = floor(y / tileSize), 
    endX   = floor((x+w) / tileSize), 
    endY   = floor((y+h) / tileSize);

    for ( int xx = startX; xx <= endX; ++xx )
    {
      for ( int yy = startY; yy <= endY; ++yy )
      {
        if ( list.indexOf( at(xx, yy) ) != -1 )
          return new TileReference(xx, yy);
      }
    }
    return null;
  }

  // Like findTileInRect(...) but returns a reference to the tile closest to the center
  public TileReference findClosestTileInRect( float x, float y, float w, float h, String list ) {
    if (mode==CENTER) {
      x-=w/2;
      y-=w/2;
    }
    if (mode==CORNERS) {
      w=w-x;
      h=h-y;
    }
    float centerX=x+w/2, centerY=y+h/2;
    int startX = floor(x / tileSize), 
    startY = floor(y / tileSize), 
    endX   = floor((x+w) / tileSize), 
    endY   = floor((y+h) / tileSize);

    int xFound=-1, yFound=-1;
    float dFound = Float.POSITIVE_INFINITY;
    for ( int xx = startX; xx <= endX; ++xx )
    {
      for ( int yy = startY; yy <= endY; ++yy )
      {
        if ( list.indexOf( at(xx, yy) ) != -1 ) {
          float d = dist(centerXOfTile(xx), centerYOfTile(yy), centerX, centerY);
          if (d<dFound) {
            dFound = d;
            xFound = xx;
            yFound = yy;
          }
        }
      }
    }
    if (dFound<Float.POSITIVE_INFINITY) return new TileReference (xFound, yFound);
    else return null;
  }

  // True if the rectangle is completely inside tiles from the list
  //The meaning of x,y,w,h is governed by mode (CORNER, CENTER, CORNERS.
  public boolean testTileFullyInsideRect( float x, float y, float w, float h, String list ) {
    if (mode==CENTER) {
      x-=w/2;
      y-=w/2;
    }
    if (mode==CORNERS) {
      w=w-x;
      h=h-y;
    }
    float centerX=x+w/2, centerY=y+h/2;
    int startX = floor(x / tileSize), 
    startY = floor(y / tileSize), 
    endX   = floor((x+w) / tileSize), 
    endY   = floor((y+h) / tileSize);

    for ( int xx = startX; xx <= endX; ++xx ) {
      for ( int yy = startY; yy <= endY; ++yy ) {
        if ( list.indexOf( at(xx, yy) ) == -1 ) return false;
      }
    }
    return true;
  }


  // Searches along the line from x1,y1 to x2,y2 for a tile from list
  // Returns the first found or null if none.
  public TileReference findTileOnLine( float x1, float y1, float x2, float y2, String list ) {
    TileReference ref = newRefOfPixel (x1, y1);
    int ctr=0;
    int maxCtr = floor(abs(x1-x2)+abs(y1-y2))/tileSize+3;
    while (ctr<=maxCtr && (ref.xPixel!=x2 || ref.yPixel!=y2)) {
      if (ctr>0) ref.advanceTowards (x2, y2);
      if (list.indexOf(at(ref.x, ref.y))!=-1) {
        ref.setBorders (); 
        return ref;
      }
      ctr++;
    }
    if (ctr>maxCtr) println ("Internal error in Map:findTileOnLine");
    return null;
  }

  // Returns, whether on the line from x1,y1 to x2,y2 there is a tile from list
  public boolean testTileOnLine ( float x1, float y1, float x2, float y2, String list ) {
    return findTileOnLine (x1, y1, x2, y2, list)!=null;
  }

  // Draws the map on the screen, where the origin, i.e. left/upper
  // corner of the map is drawn at \c leftX, topY regardless of mode
  public void draw( float leftX, float topY ) {
    pushStyle();
    imageMode(CORNER);
    int startX = floor(-leftX / tileSize), 
    startY = floor(-topY / tileSize);
    for ( int y = startY; y < startY + height/tileSize + 2; ++y ) {
      for ( int x  = startX; x < startX + width/tileSize + 2; ++x ) {
        PImage img = null;
        char tile = at( x, y );
        if ( tile == '_' )
          img = outsideImage;
        else if ('A'<=tile && tile<='Z')
          img = images[at( x, y ) - 'A'];
        if ( img != null )
          image( img, 
          x*tileSize + leftX, 
          y*tileSize + topY, 
          tileSize, tileSize );
      }
    }
    popStyle();
  } 

  // Loads a map file
  // element size is obtained from the first image loaded
  public void loadFile( String mapFile ) {
    map = loadStrings( mapFile );
    if (map==null) 
      throw new Error ("Map "+mapFile+" not found.");
    while (map.length>0 && map[map.length-1].equals (""))
      map = shorten(map);
    h = map.length;
    if ( h == 0 ) 
      throw new Error("Map has zero size");
    w = map[0].length();

    // Load images
    for (char c='A'; c<='Z'; c++) 
      images[c - 'A'] = loadImageRelativeToMap (mapFile, c + ".png" );        
    outsideImage = loadImageRelativeToMap (mapFile, "_.png");

    for ( int y = 0; y < h; ++y ) {
      String line = map[y];
      if ( line.length() != w )
        throw new Error("Not every line in map of same length");

      for ( int x = 0; x < line.length(); ++x ) {
        char c = line.charAt(x);
        if (c==' ' || c=='_') {
        }
        else if ('A'<=c && c<='Z') {
          if (images[c - 'A'] == null) 
            throw new Error ("Image for "+c+".png missing");
        }
        else throw new Error("map must only contain A-Z, space or _");
      }
    }    

    determinetileSize ();
  }

  // Saves the map into a file
  public void saveFile (String mapFile) {
    saveStrings (mapFile, map);
  }


  //********************************************************************************************
  //********* The code below this line is just for internal use of the library *****************
  //********************************************************************************************

  // Internal: load and Image and return null if not found
  protected PImage tryLoadImage (String imageFilename) {
    //println("Trying "+imageFilename);
    if (createInput(imageFilename)!=null) {
      //println("Found");
      return loadImage (imageFilename);
    }
    else return null;
  }

  // Internal: Loads an image named imageName from a locatation relative
  // to the map file mapFile. It must be either in the same
  // directory, or in a subdirectory images, or in a parallel
  // directory images.
  protected PImage loadImageRelativeToMap (String mapFile, String imageName) {
    File base = new File(mapFile);
    File parent = base.getParentFile();
    PImage img;
    img = tryLoadImage (new File (parent, imageName).getPath());
    if (img!=null) return img;
    img = tryLoadImage (new File (parent, "images/"+imageName).getPath());
    if (img!=null) return img;
    img = tryLoadImage (new File (parent, "../images/"+imageName).getPath());
    return img;
  }

  // Goes through all images loaded and determine stileSize as amx
  // If image sizes are not square and equal a warning message is printed
  protected void determinetileSize () {
    tileSize = 0;
    PImage[] allImages = (PImage[]) append (images, outsideImage);
    for (int i=0; i<allImages.length; i++) if (allImages[i]!=null) {
      if (tileSize>0 && 
        (allImages[i].width!=tileSize || allImages[i].height!=tileSize))
        println ("WARNING: Images are not square and of same size");
      if (allImages[i].width>tileSize)  tileSize = allImages[i].width;
      if (allImages[i].height>tileSize) tileSize = allImages[i].height;
    }
    if (tileSize==0) throw new Error ("No image could be loaded.");
  }

  // If the dimension of the map is below width times height
  // _ are appended in each line and full lines are appended
  // such that it is width times height.
  protected void extend (int width, int height) {
    while (height>h) {
      map = append(map, "");
      h++;
    }
    if (w<width) w = width;
    for (int y=0; y<h; y++) {
      while (map[y].length ()<w) 
        map[y] = map[y] + "_";
    }
  }

  // Replaces s.charAt(index) with ch
  public String replace (String s, int index, char ch) {
    return s.substring(0, index)+ch+s.substring(index+1, s.length());
  }


  // *** variables ***
  // tile x, y is map[y].charAt(x)
  String map[];
  // images[c-'A'] is the image for tile c
  PImage images[];
  // special image drawn outside the map
  PImage outsideImage;
  // map dimensions in tiles
  int w, h;
  // width and height of an element in pixels
  int tileSize;
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "sheepinvasion" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
