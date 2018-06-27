part of australiasim;

/// Handles view operations of the game
class GameView extends DOMView {

    /// Scale to use when converting cm to pixel
    static const _pixelScale = 0.5;

    /// Gamemode reference.
    GameMode _gameMode;

    /// LevelManger reference.
    LevelManager _levelManager;

    /// Static DOM Elements
    static final _mainElement  = querySelector("#main");
    static final _menuLayer    = querySelector("#menuLayer");
    static final _gameLayer    = querySelector("#gameLayer");
    static final _inputLayer   = querySelector("#inputLayer");
    static final _inputKnob    = querySelector("#inputKnob");

    /// Stream of movement vectors
    Stream<Vector2> onInput;
    /// Used to broadcast input events
    StreamController<Vector2> _inputEvent = new StreamController();
    
    /// To keep track of the position of the first touch in a row, 
    /// as each following touch is relative to it
    Vector2 _touchOrigin = new Vector2.zero(); 
    
    /// When a level has been chosen to play
    Stream<int> onSelectLevel;
    /// Used to broadcast select level events
    StreamController<int> _selectLevelEvent = new StreamController();

    /// If the game is currently running
    bool get isRunning => this._gameMode.isRunning;

    /// Used by the input listeners to only fire when needed.
    bool _isMoving = false;

    /// GameView constructor with given [gameMode] and [levelManager]
    GameView(GameMode this._gameMode, LevelManager this._levelManager) {

        onInput = _inputEvent.stream.asBroadcastStream();
        onSelectLevel = _selectLevelEvent.stream.asBroadcastStream(); 

        _mainElement.classes.add("loaded"); // Indicate that the game program has loaded

        _setupListeners();
    }

    /// Closes the game view and shows the menu where [failed] indicates whether the game was lost before
    closeGameView(bool failed) async {
        // Reset Game
        _gameLayer.setInnerHtml("");

        get("startGame").setInnerHtml(failed ? "RETRY!" : _levelManager.current > 0 ? "CONTINUE!" : "ENTER!");

        if (_levelManager.unlocked > 0) {
            show(get("selectLevel"));
            final levelSelection = get("levelSelection");

            for (var i = 0; i <= _levelManager.unlocked && i < _levelManager.size; i++) {
                if (get("level-${i}") == null) {
                    final lvlidx = i;
                    levelSelection.appendHtml("<button class='btn' id='level-${i}'>Level ${i + 1}</button>");
                    get("level-${i}").onClick.listen((e) => _selectLevelEvent.add(lvlidx));
                }
            }
        }

        clearCache();

        // Toggle States
        hide(_gameLayer);
        show(_menuLayer);
        activate(_menuLayer);
        deactivate(_gameLayer);
        deactivate(_inputLayer);

        await nextFrame(); // Waiting for the next frame, otherwise the css activation animations wouldn't play.

        deactivate(_mainElement);
    }

    /// Creates a new game view and hides the menu.
    openGameView() async {
        // Setup Elements
        var worldElement = get("world");

        if (get("bigLabel") == null)                create(_gameLayer, "bigLabel");
        if (worldElement    == null) worldElement = create(_gameLayer, "world");

        final statsElement = create(_gameLayer, "stats");
        final enemyCountElement = create(statsElement, "enemyCount");
        _gameMode.onEnemyCountChange.listen((count) => enemyCountElement.setInnerHtml("Enemies left: ${count}"));

        // Setup World Dimensions
        setDimensions(worldElement, _gameMode.world.size * _pixelScale);
        
        // Setup Listeners
        _gameMode.world.onActorSpawned.listen(createActor);
        _gameMode.world.onActorRemoved.listen(removeActor);
        for (var actor in _gameMode.world.actors) createActor(actor);

        // Toggle States
        show(_gameLayer);
        hide(_menuLayer);
        activate(_mainElement);
        activate(_inputLayer);

        await nextFrame();

        deactivate(_menuLayer);
        activate(_gameLayer);
    }

    /// Shows a big hint label with [text] in the upper center of the screen for the given [duration]
    hintBig(String text, Duration duration) async {

        // Setup Label
        final bigLabel = get("bigLabel");
        bigLabel.setInnerHtml(text);

        // Show Label for duration
        await timeout(duration, before: () => activate(bigLabel), after:  () => deactivate(bigLabel));
    }

    /// Creates a new [actor] in the view based on the model.
    createActor(Actor actor) {
        // Check if running
        if (!isRunning) return;

        // Check if Actor already exists.
        var el = get(actor.name);
        if (el != null) return;

        // Handle Character seperately.
        if (actor is Character) { 
            _createCharacter(actor);
            return;
        }

        // Create Actor Element
        el = create(get("world"), actor.name);

        // Mark Element as Actor
        el.classes.add("actor");

        // Make Actor circular if necessary
        if (actor.isCircleCollider) el.classes.add("circle");


        //Branch to Pawn or Prop
        if (actor is Pawn) _applyPawn(el, actor);
        else
        if (actor is Prop) _applyProp(el, actor);
    }

    /// Removes the [actor] from the view.
    removeActor(Actor actor)
    {
        remove(actor.name);
    }

    /// Creates a new Character ([char]) in the View based on the model.
    _createCharacter(Character char)
    {
        // Create Character
        final el = create(_gameLayer, char.name);
        final livesElement = create(get("stats"), "lives");

        // Mark Element as Actor and Character 
        el.classes.add("actor");
        el.classes.add("pawn");
        el.classes.add("character");
        el.attributes["position"] = "translate(-50%, -50%)";

        final world = get("world");
        // Setup listener
        moveCamera(Vector2 pos) => move(world, pos * -_pixelScale);

        _updateLives(lives) {
            var text = "";
            for (var i = 0; i < lives; i++) {
                text += "<i class='fa fa-heart'></i>";
            }
            livesElement.setInnerHtml(text);
        }

        // Register listener
        char.onMove.listen((vec) => moveCamera(vec));
        char.onRotate.listen((vec) {
            final radians = atan2(vec.x, vec.y);
            if (radians > PI * 4/5 || radians < -PI * 4/5) {  // North
                el.style.backgroundPositionY = "-525px";
            } else if (radians < -PI / 5) { // East
                el.style.backgroundPositionY = "-589px";
            } else if (radians < PI / 5) {  // South
                el.style.backgroundPositionY = "-653px";
            } else {  // West
                el.style.backgroundPositionY = "-717px";
            }
        });
        char.onScale.listen((vec) => scale(el, vec / 90.0));
        char.onLivesChange.listen(_updateLives);

        // Initial update
        moveCamera(char.location);
        scale(el, char.scale / 90.0);
        _updateLives(char.charLives);
    }

    /// Turns an Actor Element ([el]) into a [pawn].
    _applyPawn(Element el, Pawn pawn)
    {
        // Mark as pawn
        el.classes.add("pawn");

        // Add pawn listeners
        pawn.onMove.listen((vec) => move(el, vec  * _pixelScale));
        pawn.onScale.listen((vec) => scale(el, vec / 100.0));

        // Initial update
        move(el, pawn.location  * _pixelScale);
        scale(el, pawn.scale / 100.0);

        // Spiders need a rotation offset as the texture is upside down.
        if (pawn is Spider) {
            final transform = new Vector2(-1.0, 1.0);
            pawn.onRotate.listen((vec) => rotate(el, new Vector2(vec.x * transform.x, vec.y * transform.y)));
            rotate(el, new Vector2(pawn.rotation.x * transform.x, pawn.rotation.y * transform.y));
        } else {
            pawn.onRotate.listen((vec) => rotate(el, vec));
            rotate(el, pawn.rotation);
        }

        // If the pawn is generally an Enemy, branch
        if (pawn is Enemy) {
            _applyEnemy(el, pawn);
        }
    }

    /// Turns an Actor Element ([el]) into a [prop].
    _applyProp(Element el, Prop prop)
    {
        // Mark as prop
        el.classes.add("prop");

        // Initial update
        move(el, (prop.location - prop.scale / 2.0) * _pixelScale);
        rotate(el, prop.rotation);
        setDimensions(el, prop.scale * _pixelScale);

        // If the prop is the door, turn the Element into a door.
        if (prop is Door)
        {
            _applyDoor(el, prop);
        }
        else // Set the different textures and classes.
        {
           
            if (prop is Box)    el.classes.add("box");
            if (prop is Tree)   el.classes.add("tree");
            if (prop is Shrub)  el.classes.add("shrub");

            final ran = new Random(); // for random texture flavors.
            if (prop is Board)     el.style.backgroundImage = "url('./assets/img/lpc_house_insides/board${ran.nextInt(7) + 1}_32x69.png')";
            if (prop is BigBed)    el.style.backgroundImage = "url('./assets/img/lpc_house_insides/bigbed${ran.nextInt(2) + 1}_64x81.png')";
            if (prop is SmallBed)  el.style.backgroundImage = "url('./assets/img/lpc_house_insides/bed${ran.nextInt(4) + 1}_48x81.png')";
            if (prop is Lamp)      el.style.backgroundImage = "url('./assets/img/lpc_house_insides/lamp${ran.nextInt(3) + 1}_24x31.png')";
            if (prop is Table)     el.style.backgroundImage = "url('./assets/img/lpc_house_insides/table${ran.nextInt(3) + 1}_48x80.png')";
            if (prop is Flower)    el.style.backgroundImage = "url('./assets/img/lpc_house_insides/flower_30x52.png')";
        }
    }

    /// Turns an Actor Element ([el]) into a [door].
    _applyDoor(Element el, Door door) {

        // Mark as door
        el.classes.add("door");
        
        // Feedback when user touches door
        new Observable(door.onCollide)
            .throttle( new Duration(seconds: 4) )
            .where( (Actor a) => a is Character )
            .listen( (Actor a) => hintBig("You wanna leave already?", new Duration(seconds: 3)) );

        // Animate the door when it's touched
        new Observable(door.onCollide)
            .throttle( new Duration(seconds: 1) )
            .listen( (Actor a) async {
                activate(el);
                await timeout(new Duration(milliseconds: 250));
                deactivate(el);
            } );
    }

    /// Turns an Actor Element ([el]) into an [enemy].
    _applyEnemy(Element el, Enemy enemy) {

        // Mark as enemy
        el.classes.add("enemy");

        // Mark the kind of enemy
        if (enemy is Spider) el.classes.add("spider");
        if (enemy is BigSpider) el.classes.add("big");
        if (enemy is BigRedSpider) el.classes.add("red");

        // Create the cozyness bar of the
        final cozynessEl = create(el, enemy.name + "-cozyness");
        final cozynessPercentageEl = create(cozynessEl, enemy.name + "-cozyness-percentage");
        final barSize = new Vector2(max(enemy.scale.x, 100.0), 20.0) * _pixelScale;
        setDimensions(cozynessEl, barSize);
        setDimensions(cozynessPercentageEl, new Vector2(0.0, barSize.y));
        cozynessEl.classes.add("cozyness");

        // Register listener to update cozyness bar
        new Observable(enemy.onCozynessChange)
            .throttle(new Duration(milliseconds: 500))
            .listen( (double cozyness) => this.setDimensions(cozynessPercentageEl, new Vector2(barSize.x / 100 * cozyness, barSize.y)) );
        
        // Feedback when user touches enemy
        new Observable(enemy.onCollide)
            .throttle(new Duration(seconds: 4))
            .where( (Actor a) => a is Character )
            .listen( (Actor a) => hintBig("Be careful touching that!", new Duration(seconds: 3)) );
    }

    
    /// Listens on the input and passes them to events
    _setupListeners()
    {
        // Throw a selectLevelEvent with the current level when startGame was clicked
        get("startGame").onClick.listen((e) => _selectLevelEvent.add(_levelManager.current));

        // Touch listeners
        _inputLayer.onTouchStart
            .where((v) => isRunning)
            .map((e) {
                e.preventDefault();
                return new Vector2(e.touches[0].page.x, e.touches[0].page.y);
            })
            .listen(_handleInputStart);

        _inputLayer.onTouchMove
            .where((v) => isRunning)
            .map((e) {
                e.preventDefault();
                return new Vector2(e.touches[0].page.x, e.touches[0].page.y);
            })
            .listen(_handleInputMove);

        _inputLayer.onTouchEnd
            .map((e) {
                e.preventDefault();
                return new Vector2.zero(); // Reset to zero on end
            })
            .where((v) => isRunning)
            .listen(_handleInputEnd);

        // Mouse Listeners
        _inputLayer.onMouseDown
            .where((v) => isRunning)
            .map((e) {
                e.preventDefault();
                _isMoving = true;
                return new Vector2(e.page.x, e.page.y);
            })
            .listen(_handleInputStart);
            
        _inputLayer.onMouseMove
            .where((v) => isRunning && _isMoving)
            .map((e) {
                e.preventDefault();
                return new Vector2(e.page.x, e.page.y);
            })
            .listen(_handleInputMove);

        _inputLayer.onMouseUp
            .map((e) {
                e.preventDefault();
                _isMoving = false;
                return new Vector2.zero(); // Reset to zero on end
            })
            .where((v) => isRunning)
            .listen(_handleInputEnd);
    }

    /// Gets called when the user starts a touch ([vec])
    _handleInputStart(Vector2 vec)
    {
        // Update origin
        _touchOrigin = vec;

        // Move the knob to the origin
        move(_inputKnob, _touchOrigin - new Vector2(25.0, 25.0));

        // Indicate the character is moving and show the input knob
        activate(get("Character"));
        activate(_inputKnob);

        // Mark world as changing for potential optimizations in css
        get("world").classes.add("changing");
    }

    /// Gets called when the user moves the touch ([vec])
    _handleInputMove(Vector2 vec)
    {
        // Add inputEvent with relative position of the touch to the origin
        _inputEvent.add( (vec - _touchOrigin) / _pixelScale);
    }
        
    /// Gets called when the user stops the touch ([vec])
    _handleInputEnd(Vector2 vec)
    {
        _inputEvent.add(vec); // Reset velocity

        // Deactive movement indications
        deactivate(get("Character"));
        deactivate(_inputKnob);

        // Remove changing class
        get("world").classes.remove("changing");
    }
}