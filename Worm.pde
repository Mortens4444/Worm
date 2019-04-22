static final int Width = 640;
static final int Height = 480;
Wormy worm;
MovingHandler movingHandler;
FoodProvider foodProvider;
PointCounter pointCounter;
boolean inGame;
String message;
int MaxPoints = 1000;

void setup()
{
  size(640, 480);
  noStroke();
  startGame();
}

void startGame()
{
  worm = new Wormy();
  movingHandler = new MovingHandler(worm);
  foodProvider = new FoodProvider();
  pointCounter = new PointCounter();
  inGame = true;
  message = "Game over!";
}

void draw()
{
  background(0, 40, 40);
  inGame &= worm.moveForward();
  if (inGame)
  {
    worm.draw();
    
    foodProvider.getFood();
    if (worm.canConsumeFood(foodProvider.getFoodLocation()))
    {
      byte nutrition = foodProvider.getFoodNutrition();
      pointCounter.incrementWith(nutrition);
      if (pointCounter.getPoints() > MaxPoints)
      {
        message = "You won!";
        inGame = false;
      }
      foodProvider.consumeFood();
      worm.grow(nutrition);
    }
    showMessage(12, 0, 255, 255, LEFT, TOP, 0, 0, String.format("Points: %d/%d", MaxPoints, pointCounter.getPoints()));
  }
  else
  {
    showMessage(32, 255, 0, 0, CENTER, CENTER, Width / 2, Height / 2, message);
  }
}

void keyPressed() {
  movingHandler.HandleKeyPress();
}

void showMessage(int size, int r, int g, int b, int alignX, int alignY, int x, int y, String message)
{
  fill(r, g, b);
  textSize(size);
  textAlign(alignX, alignY);
  text(message, x, y);
}

class Point
{  
  private short x;
  private short y;
  
  public Point(short x, short y)
  {
    this.x = x;
    this.y = y;
  }
  
  public short getX()
  {
    return x;
  }
  
  public short getY()
  {
    return y;
  }
  
  public float getDistance(Point point)
  {
    return dist(x, y, point.x, point.y);
  }
}

class Circle
{
  private Point origo;
  private byte r;
  
  public Circle(short x, short y, byte r)
  {
    origo = new Point(x, y);
    this.r = r;
  }
  
  public short getX()
  {
    return origo.getX();
  }
  
  public short getY()
  {
    return origo.getY();
  }
  
  public Point getOrigo()
  {
    return origo;
  }
  
  public byte getRadius()
  {
    return r;
  }
  
  public void draw(int red, int green, int blue)
  {
    fill(red, green, blue);
    ellipse(origo.getX(), origo.getY(), r, r);
  }
}

class Wormy
{
  private static final byte NumberOfBodyParts = 10;  
  private ArrayList<Circle> body = new ArrayList<Circle>();
  private DirectionProvider directionProvider = new DirectionProvider();
  private Direction movingDirection = Direction.East;
  public static final byte BodyRadius = 30;  
  
  public Wormy() {
    short x = Width / 2;
    short y = Height / 2;

    for (byte i = 0; i < NumberOfBodyParts; i++)
    {
      body.add(new Circle((short)(x + i * DirectionProvider.PixelsToMove), (short)y, BodyRadius));
    }
  }
  
  public void draw()
  {
    for (int i = 0; i < body.size(); i++)
    {
      body.get(i).draw(204, 102, 0);
    }
    drawHead();
  }
  
  public boolean moveForward()
  {
    body.remove(0);
    Circle head = getHead();
    Point movingModifier = directionProvider.getDirection(movingDirection);
    body.add(new Circle((short)(head.getX() + movingModifier.getX()), (short)(head.getY() + movingModifier.getY()), BodyRadius));
    
    if (head.getX() < 0 || head.getX() > Width || head.getY() < 0 || head.getY() > Height || hasCollision())
    {
      return false;
    }
    
    return true;
  }
  
  public Direction getDirection()
  {
    return movingDirection;
  }
  
  public void changeDirection(Direction newDirection)
  {
    int sum = movingDirection.getValue() + newDirection.getValue();
    if (sum != 0)
    {
      movingDirection = newDirection;
    }
  }
  
  public boolean canConsumeFood(Point foodLocation)
  {
    for (int i = 0; i < body.size(); i++)
    {
      Circle circle = body.get(i);
      Point origo = circle.getOrigo();
      if (origo.getDistance(foodLocation) < BodyRadius)
      {
        return true;
      }
    }
    return false;
  }
  
  public void grow(byte nutrition)
  {
    byte count = byte(nutrition / 5);
    Circle tail = getTail();
    for (byte i = 0; i < count; i++)
    {
      body.add(0, new Circle(tail.getX(), tail.getY(), BodyRadius));
    }
  }
  
  private boolean hasCollision()
  {
    Point headOrigo = getHead().getOrigo();
    for (int i = 0; i < body.size() - 20; i++)
    {
      Circle circle = body.get(i);
      Point origo = circle.getOrigo();
      if (origo.getDistance(headOrigo) < BodyRadius)
      {
        return true;
      }
    }
    return false;
  }

  private Circle getHead()
  {
    return body.get(body.size() - 1);
  }
  
  private Circle getTail()
  {
    return body.get(0);
  }
  
  private void drawHead()
  {
    fill(0);
    Circle head = getHead();
    short headX = head.getX();
    short headY = head.getY();
    byte r = 2;
    ellipse(headX + 10, headY - 2, r, r);
    ellipse(headX + 10, headY + 2, r, r);    
  }
}

enum Direction
{
  East(1),
  West(-1),
  South(2),
  North(-2);

  private final int id;
  private Direction(int id)
  {
    this.id = id;
  }
  
  public int getValue()
  {
    return id;
  }
}

class DirectionProvider
{
  public static final byte PixelsToMove = 3;
  private HashMap<Direction, Point> directions = new HashMap<Direction, Point>();
  
  public DirectionProvider()
  {
    directions.put(Direction.East, new Point(PixelsToMove, (short)0));
    directions.put(Direction.West, new Point((short)-PixelsToMove, (short)0));
    directions.put(Direction.South, new Point((short)0, PixelsToMove));
    directions.put(Direction.North, new Point((short)0, (short)-PixelsToMove));
  }

  public Point getDirection(Direction direction)
  {
    return directions.get(direction);
  }
}

class MovingHandler
{
  private Wormy worm;
  
  public MovingHandler(Wormy worm)
  {
    this.worm = worm;
  }
  
  public void HandleKeyPress()
  {
    switch (key)
    {
      case CODED:
        switch (keyCode)
        {
          case RIGHT:
            worm.changeDirection(Direction.East);
            break;
          case LEFT:
            worm.changeDirection(Direction.West);
            break;
          case DOWN:
            worm.changeDirection(Direction.South);
            break;
          case UP:
            worm.changeDirection(Direction.North);
            break;
        }
        break;
      case ' ':
        if (!inGame)
        {
          startGame();
        }
      break;
    }
  }
}

class FoodProvider
{
  private boolean foodAvailable = false;
  private Circle circle;
  private static final int FoodRadius = Wormy.BodyRadius - 10;
  
  public void getFood()
  {
    if (foodAvailable)
    {
      circle.draw(200, 0, 0);
      return;
    }
    
    short x = (short)random(FoodRadius, Width - FoodRadius);
    short y = (short)random(FoodRadius, Height - FoodRadius);    
    circle = new Circle(x, y, (byte)FoodRadius);
    
    foodAvailable = true;
  }
  
  public Point getFoodLocation()
  {
    return circle.getOrigo();
  }
  
  public void consumeFood()
  {
    foodAvailable = false;
  }
  
  public byte getFoodNutrition()
  {
    return byte(random(20));
  }
}

class PointCounter
{
  private int points = 0;
  
  public void incrementWith(byte amount)
  {
    points += amount;
  }
  
  public int getPoints()
  {
    return points;
  }
}