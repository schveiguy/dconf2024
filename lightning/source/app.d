import std.stdio;
import raylib;

void main()
{
    InitWindow(800, 800, "Dconf 2024!");
    SetTargetFPS(60);
    auto img = LoadTexture("logo-512.png");
    int rotation = 0;
    bool takeoff = false;
    auto pos = Vector2((GetScreenWidth() - img.width) / 2, GetScreenHeight() - img.height);
    float v = 0;
    while(!WindowShouldClose()) {
        BeginDrawing();
        scope(exit) EndDrawing();
        if(IsKeyDown(KeyboardKey.KEY_D)) takeoff = true;
        if(takeoff) {
            if(rotation >= 60)
            {
                pos.y -= v;
                v += 0.1;
            }
            else {
                rotation += 1;
            }
        }

        ClearBackground(Colors.BLACK);
        DrawText("Hello, DCONF!", 10, 10, 50, Colors.WHITE);
        DrawTextureEx(img, pos, -rotation, 1.0, Colors.WHITE);
    }
}
