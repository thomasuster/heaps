package h3d.parts;

enum Value {
	VConst( v : Float );
	VLinear( start : Float, len : Float );
	VPow( start : Float, len : Float, pow : Float );
	VSin( freq : Float, ampl :  Float, offset : Float );
	VCos( freq : Float, ampl :  Float, offset : Float );
	VPoly( values : Array<Float>, points : Array<Float> );
	VRandom( start : Float, len : Float, converge : Converge );
	VCustom( lifeToValue : Float -> (Void -> Float) -> Float ); // time -> random -> value
}

enum Converge {
	No;
	Start;
	End;
}

enum Shape {
	SDir( x : Float, y : Float, z : Float );
	SSphere( radius : Float );
	SSector( radius : Float, angle : Float  );
	SCustom( initPartPosDir : Emiter -> Particle -> Void ); // Bool = on shell
}

class ValueXYZ {
	
	public var vx : Value;
	public var vy : Value;
	public var vz : Value;
	
	public function new(x, y, z) {
		this.vx = x;
		this.vy = y;
		this.vz = z;
	}
	
}

class ColorKey {
	
	public var time : Float;
	public var r : Float;
	public var g : Float;
	public var b : Float;
	public var next : ColorKey;
	
	public function new(time, r, g, b) {
		this.time = time;
		this.r = r;
		this.g = g;
		this.b = b;
	}
	
}

enum BlendMode {
	Add;
	Alpha;
	SoftAdd;
}

enum SortMode {
	Front;
	Back;
	Sort;
	InvSort;
}

class State {
	
	// material
	public var textureName : String;
	public var frames : Array<h2d.Tile>;
	public var blendMode : BlendMode;
	public var sortMode : SortMode;
	
	// emit
	public var loop	: Bool;
	public var emitRate : Value;
	public var bursts : Array<{ time : Float, count : Int }>;
	public var maxParts : Int;
	public var shape : Shape;
	public var emitFromShell : Bool;
	public var randomDir : Bool;

	// system globals
	public var globalLife : Float;
	public var globalSpeed : Value;
	public var globalSize : Value;
	
	// particle globals
	public var life : Value;
	public var size : Value;
	public var ratio : Value;
	public var rotation : Value;
	public var speed : Value;
	public var gravity : Value;
	
	// effects
	public var force : Null<ValueXYZ>;
	public var colors : Null<Array<{ time : Float, color : Int }>>;
	public var light : Value;
	public var alpha : Value;
	
	// collide
	public var collide : Bool;
	public var collideKill : Bool;
	public var bounce : Float;
	
	// animation
	public var frame : Null<Value>;
	
	public function new() {
	}
	
	public function setDefaults() {
		// material
		textureName = null;
		frames = null;
		blendMode = SoftAdd;
		sortMode = Back;
		// emit
		loop = true;
		emitRate = VConst(100);
		bursts = [];
		maxParts = 1000;
		shape = SSphere(1);
		emitFromShell = false;
		randomDir = false;
		// system globals
		globalLife = 1;
		globalSpeed = VConst(1);
		globalSize = VConst(1);
		// particles globals
		life = VConst(1);
		size = VConst(1);
		ratio = VConst(1);
		rotation = VConst(0);
		speed = VConst(0.1);
		gravity = VConst(0);
		// effects
		force = null;
		colors = null;
		light = VConst(1);
		alpha = VConst(1);
		// collide
		collide = false;
		collideKill = false;
		bounce = 0;
	}
	
	public /*inline*/ function eval( v : Value, time : Float, rand : Void -> Float ) : Float {
		return switch( v ) {
		case VConst(c): c;
		case VRandom(s, l, c): s + (switch( c ) { case No: l; case Start: l * time; case End: l * (1 - time); }) * rand();
		case VLinear(s, l): s + l * time;
		case VPow(s, l, p): s + Math.pow(time, p) * l;
		case VSin(f, a, o): Math.sin(time * f) * a + o;
		case VCos(f, a, o): Math.cos(time * f) * a + o;
		case VPoly(values,_):
			var y = 0.0;
			var j = values.length - 1;
			while( j >= 0 ) {
				y = values[j] + (time * y);
				j--;
			}
			y;
		case VCustom(f): f(time, rand);
		}
	}
	
}