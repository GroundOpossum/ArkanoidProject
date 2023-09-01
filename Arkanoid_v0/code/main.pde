// arkanoid = https://www.dailymotion.com/video/x5f1vv //<>//
/////////////////////////////////////////////////////
//
// Arkanoid
// DM2 "UED 131 - Programmation impérative" 2022-2023
// NOM         : MF
// 
// Collaboration avec : Univ Evry
//
/////////////////////////////////////////////////////

//===================================================
// les variables globales
//===================================================

/////////////////////////////
// Pour les effets sonores //
/////////////////////////////
import processing.sound.*;
SoundFile intro;
SoundFile brique;
SoundFile gameover;
SoundFile letsgo;
SoundFile mur;
SoundFile raquette;
SoundFile boss;

/////////////////////////////
// Pour la balle           //
/////////////////////////////
float balleD;
float balleX;
float balleY;
float balleVitesse = 10;
float balleVx;
float balleVy;
float newBalleX;
float newBalleY;
/////////////////////////////
// Pour la raquette        //
/////////////////////////////
int raquetteX;
int raquetteY;
int raquetteL;
int raquetteH;
/////////////////////////////
// Pour la zone de jeu     //
/////////////////////////////
int minX = 0+30;
int maxX = 710-30;
int minY = 0+30;
int maxY = 630-30;
int centreX;
/////////////////////////////
// Pour les briques        //
/////////////////////////////
final int nbLignes = 8;
final int nbColones = 13;
int nbBriques;
final int briqueL = 50;
final int briqueH = 25;
ArrayList<PVector> briques = new ArrayList<PVector>();
color[] couleurs = new color[nbLignes];

/////////////////////////////
// Pour le "boss"          //
/////////////////////////////

  int BossH = 200;
  int BossW = 200;
  int middleL;
  int middlel;
  int vieBoss = 10;

/////////////////////////////
// Pour le contrôle global //
/////////////////////////////
int nmbrVie = 3;
final int INIT = 0;
final int GO = 1;
final int OVER = 2;
final int WIN = 3;
int etat = INIT;
boolean isInit = false; 
boolean isPaused = false;
////////////////////////////////////
// Pour la gestion de l'affichage //
////////////////////////////////////

int score = 0;
String sscore = formatScore(score);
int highscore = score;
String shighscore = sscore;

//===================================================
// l'initialisation
//===================================================
void setup() {
  size(960, 630);
initJeu();
            
}

//===================================================
// l'initialisation de la balle et de la raquette
//===================================================
void initBalleEtRaquette() {
  raquetteX = 355;
  raquetteY = 580;
  raquetteL = 100;
  raquetteH = 20;
  balleD = 10;
  balleX = 355 ;
  balleY = 565 ;
  balleVx = balleVitesse * cos(random(5*PI/4, 7*PI/4)); 
  balleVy = balleVitesse * sin(random(5*PI/4, 7*PI/4));
}

//===================================================
// l'initialisation des briques
//===================================================
void initBriques() {
  briques.clear();
  int tempX = 30-(briqueL/2);
  int tempY = 30+14;
    for(int i=1; i<=nbLignes;i++){
     tempX = 30-(briqueL/2);
     tempY = tempY + briqueH  ;
    for (int j=1; j<=nbColones; j++){
      
      tempX = tempX + briqueL ;
      briques.add(new PVector(tempX,tempY));
    }
    }
    nbBriques = (nbLignes*nbColones);
}

//===================================================
// l'initialisation de la partie
//===================================================
void initJeu() {
  initBalleEtRaquette();
  initBriques();
  //initJeu();
  // Sounds
  intro = new SoundFile(this, "../data/intro.mp3");
  gameover = new SoundFile(this,"../data/gameover.mp3");
  letsgo = new SoundFile(this,"../data/letsgo.mp3");
  mur = new SoundFile(this,"../data/mur.mp3");
  raquette = new SoundFile(this,"../data/raquette.mp3");
  brique = new SoundFile(this,"../data/brique.mp3");
  boss = new SoundFile(this, "../data/oof.mp3");
}

//===================================================
// la boucle de rendu
//===================================================
void draw() {
    afficheJeu();
  if (etat == INIT){
    if (!isInit){
    isInit = true;
    intro.play();
    }

    afficheEcran("GET READY",69);
  }
  if (etat == WIN){
           resetLives();
       score = 0;
             initBalleEtRaquette();
             initBriques();
    afficheEcran("WIN",60);
  }
  if (etat == GO && !isPaused){
  deplaceBalle();
  rebondRaquette();
  if (nbBriques == 0){
    rebondBoss(balleX,balleY,newBalleX,newBalleY);
  }

  rebondBriques(balleX,balleY,newBalleX,newBalleY);
  miseAJourBalle();
    rebondMurs();
    isInit = false;
  }
  if (etat == OVER){
      initBalleEtRaquette();
  afficheEcran("GAME OVER",nmbrVie);
  if (nmbrVie <= 0){
     initBriques();
   }

  }
  
  // HIGHSCORE UPDATE
  if (score > highscore){
  shighscore = sscore;
    
  }
  
}

//===================================================
// gère les rebonds sur les murs
//===================================================
void rebondMurs() {
  //Rebond sur le coté droit
  if(newBalleX+(balleD/2) >= maxX){
    
    balleVx = -balleVx;
    mur.play();
  }
  //Rebond sur le coté gauche
  if(newBalleX-(balleD/2) <= minX){
    balleVx = -balleVx;
    mur.play();
  }
  //Rebond sur le coté haut
  if(newBalleY-(balleD/2) <= minY){
        balleVy = -balleVy;
        mur.play();
  }
  // Rebond sur le coté bas
  if (newBalleY-(balleD/2) >= maxY+30){
  nmbrVie--;
  sscore = formatScore(score);
  gameover.play();
  etat = OVER;
  }
}

//===================================================
// gère le rebond sur la raquette
//===================================================
void rebondRaquette() {

  // Si la balle avant modification est au dessus du bord supérieur de la raquette Et que la balle après modification est en dessous du bord supérieur de la raquette
  if (balleY+(balleD) < (raquetteY-(raquetteH/2)) && (newBalleY+(balleD)) > (raquetteY-(raquetteH/2)) // TODO
  // Et que la balle après modification est entre le bord gauche et celui du bord droit de la raquette
  && newBalleX > (raquetteX-(raquetteL/2)) && newBalleX < (raquetteX+(raquetteL/2)))
  {
    raquette.play();
    balleVy = -balleVy;
  } 
}

//===================================================
// gère le rebond sur une "boîte"
// --------------------------------------------------
// (x1, y1) = l'ancienne position de la balle
// (x2, y2) = la nouvelle position de la balle
// (bx, by) = le coin supérieur gauche de la boîte
// (bw, bh) = la largeur et la hauteur de la boîte
// --------
// résultat = vrai si rebond / faux sinon
// --------
// met à jour la vitesse de la balle en fonction du 
// rebond
//===================================================
boolean rebond(float x1, float y1, float x2, float y2, 
  float bx, float by, float bw, float bh) {
    
        if (((y1 <= by && y2 >= by) || y1 >= (by+bh)&& y2 <= (by+bh)) && ((x2 > bx ) && (x2 < (bx+bw)))){
      balleVy = -balleVy;
    return true;

}
    if (((x1 <= bx && x2 >= bx) || x1 >= (bx+bw) && x2 <= (bx+bw)) && ((y2 > by) && (y2 < (by+bh)) ) ){
          balleVx = -balleVx;
    return true;
    }
    

  return false;
  }

//===================================================
// gère le rebond sur les briques
// --------------------------------------------------
// (x1, y1) = l'ancienne position de la balle
// (x2, y2) = la nouvelle position de la balle
//===================================================
void rebondBriques(float x1, float y1, float x2, float y2) {
          for (int i = briques.size() - 1; i >= 0; i--) {
            PVector briqueV = briques.get(i);
     if (rebond(x1,y1,x2,y2,(briqueV.x-briqueL/2), (briqueV.y-briqueH/2),briqueL,briqueH )){
       briques.set(briques.indexOf(briqueV), new PVector(-100,-100));
       brique.play();
      score = score + 10;
      sscore = formatScore(score);
       nbBriques--;
     }
     }
}

//===================================================
// réinitialise la vie du joueur/boss au besoin
// --------------------------------------------------
void resetLives(){
nmbrVie = 3;
vieBoss = 10;
}

//===================================================
// gère le rebond sur le boss
// --------------------------------------------------
// (x1, y1) = l'ancienne position de la balle
// (x2, y2) = la nouvelle position de la balle
//===================================================
void rebondBoss(float x1, float y1, float x2, float y2) {
  if (rebond(x1,y1,x2,y2,(middleL-(BossW/2)),(middlel-(BossH/2)), BossW,BossH)){
    score = score + 10;
    sscore = formatScore(score);
    vieBoss--;
    boss.play();
    if (vieBoss <= 0){
    etat = WIN;
    }
  }
}

//===================================================
// calcule la nouvelle position de la balle
//===================================================
void deplaceBalle() {
  newBalleX = balleX+balleVx;
  newBalleY = balleY+balleVy;
}

//===================================================
// met à jour la position de la balle
//===================================================
void miseAJourBalle() {
  balleX = newBalleX;
  balleY = newBalleY;
}

//===================================================
// affiche un écran, avec un message
// --------------------------------------------------
// msg = le message à afficher
//===================================================
void afficheEcran(String msg, int NmbVie) {
  
  if (msg == "GET READY"){
  PImage templogo = loadImage("../data/arkanoid.png");
  imageMode(CENTER);
  image(templogo, 355,375, 500,112);
  PFont joystix = createFont("../data/joystix.ttf", 40);
  textFont(joystix);
  textAlign(CENTER);
  fill(#C6BCB3);
  text("GET READY", 355, 480);
  textSize(20);
  text("PRESS <SPACE> TO START", 355, 520);
  imageMode(CORNER);
  }
  if (msg == "GAME OVER"){
  PFont joystix = createFont("../data/joystix.ttf", 40);
  textFont(joystix);
  textAlign(CENTER);
  fill(#FF0000);
  if (NmbVie <= 0){
    text("GAME OVER", 355, 480);
  }else{
    
    text("GAME OVER", 355, 430);
      fill(#999999);
      textSize(30);
          text(NmbVie+" lives remains!", 355, 470);
            fill(#FF0000);
                  textSize(40);
          
  }

  textSize(20);
  text("PRESS <SPACE> TO RESTART", 355, 520);
  }
  
  if (msg == "WIN"){
    
    PImage templogo = loadImage("../data/arkanoid.png");
  imageMode(CENTER);
  image(templogo, 355,375, 500,112);
  PFont joystix = createFont("../data/joystix.ttf", 40);
  textFont(joystix);
  textAlign(CENTER);
  fill(#99FF99);
  text("You won! ", 355, 480);
  textSize(20);
  text("PRESS <SPACE> TO RESTART A GAME!", 355, 520);
  imageMode(CORNER);
  }
}

//===================================================
// fait le dessin de pavage au fond
//===================================================
void pavage() { 
  PImage tile;
  tile = loadImage("../data/tile.png");
  int pavX = 0;
  for(int i=0; i<=8;i++){
  int pavY = 0;
    for (int j=0; j<=8; j++){
      image(tile, pavX, pavY);
      image(tile, pavX+65, pavY-38);
      pavY = pavY + 76;
    }
    pavX = pavX + 130;
  }
}

//===================================================
// affiche le cadre
//===================================================
void cadre() {
  //background(0, 60, 130);
  //Cadre gris
  /*noFill();
  strokeWeight(30);
  stroke(128, 128, 128);
  rect(0, 0, 710, 630);*/
  //Cadre Image
  PImage cadretop = loadImage("../data/top.png"), wall1 = loadImage("../data/wall1.png"), wall2 = loadImage("../data/wall2.png");
  image(cadretop,0,0);
  int posYWall = 30;
    for (int i = 0 ; i < 6 ; i = i + 1){
      image(wall2, 0, posYWall);
      image(wall1, 0, posYWall+65);
      image(wall2, 680, posYWall);
      image(wall1, 680, posYWall+65);
      posYWall = posYWall + 105;
    }
}

//===================================================
// formate le score sur 6 chiffres
// --------------------------------------------------
// score = le score à afficher
// --------
// résultat = une chaîne de caractères sur 6 chiffres
//===================================================
String formatScore(int score) {
  
  String TempScore = str(score);
  
  while (TempScore.length() <= 6){
  TempScore = "0"+TempScore;
}

  return TempScore;
}

//===================================================
// affiche le cartouche de droite
//===================================================
void cartouche() {
  PImage logo = loadImage("../data/arkanoid.png");
  PFont joystix = createFont("../data/joystix.ttf", 20);
  //CARTOUCHE
  noStroke();
  fill(#000000);
  rect(710, 0, 250, 630);
  //LOGO
  imageMode(CORNER);
  image(logo, 710, 0);
  //SCORE
  textFont(joystix);
  textAlign(CENTER);
  fill(#FF3030);
  text(nmbrVie+"UP", 835, 100);
  //CURRENT SCORE
  text("SCORE :\n"+sscore, 830,280);
  //HIGHSCORE
  text("HIGH SCORE\n"+shighscore, 830, 200);
  //COPYRIGHT
  text("COPYRIGHT", 830, 550);
  text("MF", 830, 580);
  text("c  2022", 830, 610);

  if (isPaused){
  textFont(joystix);
  textAlign(CENTER);
  fill(#C6BCB3);
  text("MOUSE NOT \nDETECTED", 830, 450);
}
}

//===================================================
// affiche le boss dans sa cage
//===================================================
void boss() {
  PImage cage = new PImage(BossH,BossW);
  cage = loadImage("../data/cage.png");
  middleL = 710/2;
  middlel = 630/4; 
  pushMatrix();
  translate(middleL, middlel-55);
  strokeWeight(2);
  //Link Hat
  fill(#0ff607);
  stroke(#26a122);
  beginShape();
  curveVertex(-10, 0);
  curveVertex(-10, 0);
  curveVertex(-30, -20);
  curveVertex(-10, -40);
  curveVertex(20, -30);
  curveVertex(50, -10);
  curveVertex(0, 0);
  curveVertex(0, 0);
  endShape();
  //Character
  fill(#FFFFFF);
  strokeWeight(5);
  stroke(#4040FF);
  //Head
  ellipseMode(CENTER);
  ellipse(0, 0, 50, 50);
  //Body
  line(0, 25, 0, 100);
  //Right Arm
  line(0, 40, 30, 70);
  //Left Arm
  line(0, 43, -40, 70);
  //Right Leg
  line(0, 100, 15, 130);
  //Left leg
  line(-5, 100, -35, 150);
  //EyeBrows
  line(2, -6, 6, -10);
  line(-7, -7, -12, -10);
  //Eyes
  point(5, -5);
  point(-10, -5);
  //Mouth
  noFill();
  arc(0, 5, 15, 10, radians(0), radians(180));
  //ButterKnife Handle
  translate(30, 70);
  fill(#000000);
  noStroke();
  rotate(radians(30));
  rect(-5, 0, 10, -40, 0, 0, 10, 10);
  //ButterKnife blade
  fill(#AAAAAA);
  rect(-8, -35, 20, -50, 10);
  //Cage
  popMatrix();
  imageMode(CENTER);
  image(cage, middleL, middlel, BossH, BossW);
}

//===================================================
// affiche la balle
//===================================================
void afficheBalle() {
  ellipseMode(CENTER);
  fill(#FFFFFF);
  ellipse(balleX, balleY, balleD, balleD);
}

//===================================================
// affiche la raquette
//===================================================
void afficheRaquette() {
  rectMode(CENTER);
  fill(#FFFFFF);
  rect(raquetteX, raquetteY, raquetteL, raquetteH, 50);
  rectMode(CORNER);
}

//===================================================
// affiche les briques
//===================================================

void affichebriques(){
   rectMode(CENTER);
   int ligneActuelle = 1;
   int tempBriqueLigne = 0;
   for(PVector briqueV : briques){
    if (tempBriqueLigne >= nbColones){
    ++ligneActuelle;
    tempBriqueLigne = 0;
    }
    colorMode(HSB,359,100,100);
    fill(((360/nbLignes)*ligneActuelle-(360/nbLignes)),75,100);
    rect(briqueV.x,briqueV.y,briqueL,briqueH,10);
    tempBriqueLigne++;
  }
        rectMode(CORNER);
}

//===================================================
// affiche le jeu
//===================================================
void afficheJeu() {
  pavage();
  cadre();
  boss();
  afficheRaquette();
  afficheBalle();
  affichebriques();
  cartouche();
}

//===================================================
// gère les interactions clavier
//===================================================
void keyPressed() {
  if (key == ' ' && (etat == INIT|| etat == OVER || etat == WIN)){
    intro.stop();
    etat = GO;
    letsgo.play();
    delay(3200);
    if (nmbrVie <= 0){ // Restart
    resetLives();
       }
       if (etat == WIN) {etat = GO;}
  }
  
}

//===================================================
// gère les interactions souris
//===================================================
void mouseMoved() {
  if (mouseX < minX || mouseX > maxX){
  afficheRaquette();
  isPaused = true;
  return;
  }
  if (!(etat == OVER || etat == INIT || etat == WIN)){
  if ((mouseX - (raquetteL/2) < minX)){
  raquetteX = minX + (raquetteL/2);
  }else if(mouseX + (raquetteL/2) > maxX){
  raquetteX = maxX - (raquetteL/2);
  }else{
      raquetteX = mouseX;
  }
  }
  
    isPaused = false;
}
