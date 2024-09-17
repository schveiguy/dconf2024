import std.stdio;
import raylib;

import heap;
import std.random;

struct Stuff {
    ulong value;
    Node!Stuff phnode;
}

	static ptrdiff_t stuffCmp(Stuff* lhs, Stuff* rhs) {
		auto l = cast(size_t) lhs;
		auto r = cast(size_t) rhs;

		return (lhs.value == rhs.value)
			? (l > r) - (l < r)
			: (lhs.value - rhs.value);
	}

enum CSIZE = 24;
enum FSIZE = 12;
int drawNode(Stuff* stuff) {
    int depth = 0;
    DrawCircle(CSIZE, CSIZE, CSIZE - 2, Colors.LIGHTGRAY);
    auto txt = TextFormat("%d", stuff.value);
    DrawText(txt, CSIZE - (MeasureText(txt, FSIZE) / 2), CSIZE - FSIZE / 2, FSIZE, Colors.BLACK);
    if(stuff.phnode.next.node)
    {
        Vector2 start = Vector2(CSIZE + CSIZE - 2, CSIZE);
        Vector2 end = start + Vector2(CSIZE, 0);
        DrawLineV(start, end, Colors.BLACK);
        DrawTriangle(end, end + Vector2(-5, -2.5), end + Vector2(-5, 2.5), Colors.BLACK);
        rlPushMatrix();
        scope(exit) rlPopMatrix();
        rlTranslatef(CSIZE + CSIZE - 2 + CSIZE - 2, 0, 0);
        depth += drawNode(stuff.phnode.next.node);
    }

    if(stuff.phnode.child.node)
    {
        Vector2 start = Vector2(CSIZE, CSIZE  + CSIZE - 2);
        Vector2 end1 = start + Vector2(0, CSIZE + (CSIZE + CSIZE - 2) * depth);
        Vector2 end2 = end1 + Vector2(CSIZE / 2, 0);
        DrawLineV(start, end1, Colors.BLACK);
        DrawLineV(end1, end2, Colors.BLACK);
        DrawTriangle(end2, end2 + Vector2(-5, -2.5), end2 + Vector2(-5, 2.5), Colors.BLACK);
        rlPushMatrix();
        scope(exit) rlPopMatrix();
        rlTranslatef(end2.x - 2, end2.y - CSIZE, 0);
        depth += 1 + drawNode(stuff.phnode.child.node);
    }
    return depth;
}
void main()
{
    Stuff[128] stuffs;

	foreach (i; 0 .. stuffs.length) {
		stuffs[i].value = cast(ubyte)i;
	}
	Heap!(Stuff, stuffCmp) theHeap;

    auto nodes = stuffs[];
    import std.range;
    void insertNext() {
        if(nodes.empty)
            return;
        theHeap.insert(&nodes.front());
        nodes.popFront;            
    }
    insertNext();

    InitWindow(800, 800, "Heap demo");
    while(!WindowShouldClose())
    {
        import std.algorithm;
        BeginDrawing();
        scope(exit) EndDrawing();
        if(IsKeyPressed(KeyboardKey.KEY_SPACE))
        {
            insertNext();
        }
        if(IsKeyPressed(KeyboardKey.KEY_X))
        {
            theHeap.clear();
            nodes = stuffs[];
            insertNext();
        }
        if(IsKeyPressed(KeyboardKey.KEY_R))
        {
            theHeap.clear();
            nodes = stuffs[];
            nodes[].map!(function ref ulong(ref Stuff v) => v.value).randomShuffle;
            insertNext();
        }
        if(IsKeyPressed(KeyboardKey.KEY_B))
        {
            nodes[].map!(function ref ulong(ref Stuff v) => v.value).randomShuffle;
        }
        if(IsKeyPressed(KeyboardKey.KEY_O))
        {
            theHeap.clear();
            nodes[].map!(function ref ulong(ref Stuff v) => v.value).sort;
            insertNext();
        }
        if(IsKeyPressed(KeyboardKey.KEY_I))
        {
            theHeap.clear();
            nodes[].map!(function ref ulong(ref Stuff v) => v.value).sort!((a, b) => a > b);
            insertNext();
        }
        if(IsKeyPressed(KeyboardKey.KEY_P))
        {
            theHeap.pop();
        }

        ClearBackground(Colors.WHITE);

        drawNode(theHeap.top);
    }
}
