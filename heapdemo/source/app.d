import std.stdio;
import raylib;

import heap;
import std.random;

struct Stuff {
    ulong value;
    Node!Stuff phnode;
}

int numComparisons = 0;

ptrdiff_t stuffCmp(Stuff* lhs, Stuff* rhs) {
    auto l = cast(size_t) lhs;
    auto r = cast(size_t) rhs;
    ++numComparisons;

    return (lhs.value == rhs.value)
        ? (l > r) - (l < r)
        : (lhs.value - rhs.value);
}

enum CSIZE = 24;
enum FSIZE = 12;
int drawNode(Stuff* stuff) {
    if(stuff is null) return 0;
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
    int numOps;
    void insertNext() {
        if(nodes.empty)
            return;
        ++numOps;
        theHeap.insert(&nodes.front());
        nodes.popFront;            
    }

    void reset() {
        theHeap.clear();
        numComparisons = 0;
        numOps = 0;
    }

    insertNext();

    InitWindow(800, 800, "Heap demo");

    SetTargetFPS(60);

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
            reset();
            nodes = stuffs[];
            insertNext();
        }
        if(IsKeyPressed(KeyboardKey.KEY_R))
        {
            reset();
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
            reset();
            nodes = stuffs[];
            nodes[].map!(function ref ulong(ref Stuff v) => v.value).sort;
            insertNext();
        }
        if(IsKeyPressed(KeyboardKey.KEY_I))
        {
            reset();
            nodes = stuffs[];
            nodes[].map!(function ref ulong(ref Stuff v) => v.value).sort!((a, b) => a > b);
            insertNext();
        }
        if(IsKeyPressed(KeyboardKey.KEY_P))
        {
            ++numOps;
            theHeap.pop();
        }

        ClearBackground(Colors.WHITE);
        auto txt = TextFormat("Cmp: %d Ops: %d", numComparisons, numOps);
        DrawText(txt, GetScreenWidth() - 10 - MeasureText(txt, 20), 10, 20, Colors.BLACK);
        drawNode(theHeap.top);
    }
}
