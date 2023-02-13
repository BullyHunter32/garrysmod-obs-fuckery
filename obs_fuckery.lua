
local trail = {
    [0] = 0
}
local maxTrail = 200
local interval = 0.1
local lastTrail = 0

local rt = GetRenderTargetEx("fat fsuckss", ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_ONLY, 16, CREATERENDERTARGETFLAGS_HDR, IMAGE_FORMAT_RGB888)
local matColorIgnoreZ = Material( "color_ignorez" )

hook.Add("PostDrawOpaqueRenderables", "", function() EyePos() end)

hook.Add("PostRender", "", function()

    render.PushRenderTarget(rt)
    render.Clear(0, 0, 0, 0, true, true)    

    if CurTime() - lastTrail > interval then
        local pos = LocalPlayer():GetPos()
        trail[0] = trail[0] + 1
        trail[trail[0]] = pos

        if trail[0] > maxTrail then
            table.remove(trail, 1)
            trail[0] = trail[0] - 1
        end
    end
    
    render.SuppressEngineLighting(true)
    cam.Start3D()
    cam.IgnoreZ(true)
        render.SetColorModulation(1, 1, 0)
        render.SetLightingMode(1)
        local prevPos
        for i = 1, trail[0] do
            local pos = trail[i]
            if not prevPos then
                prevPos = pos
                goto skip
            end

            render.SetColorMaterial()
            render.DrawBeam(prevPos, pos, 1, 1, 1, Color(125, 0, 255))
            prevPos = pos
            ::skip::
        end

        -- render.SetColorMaterialIgnoreZ()
        for k, v in ipairs(player.GetAll()) do
            v.oModel = v:GetModel()

            if v == LocalPlayer() then
                render.SetColorModulation(0, 1, 0.369)
                v:SetModel("models/tdmcars/bus.mdl")
                v:SetModelScale(0.2)
            else
                render.SetColorModulation(0, 0, 1)
                v:SetModel("models/tdmcars/gtaiv_airtug.mdl")
            end
            v:DrawModel()

            local wep = v:GetActiveWeapon()
            if IsValid(wep) then
                wep:DrawModel()
            end

            local diff = EyePos() - v:GetPos()
            diff = diff:Angle()
 
            cam.Start3D2D(v:GetPos() - v:GetUp()*10, Angle(0, diff.y + 90, 90), 0.8)
                draw.SimpleText(v:Nick(), "ChatFont", 0, 0, color_white, 1, 1)
            cam.End3D2D()

            render.SetLightingMode(0)

            ::skip::
        end
        cam.IgnoreZ(false)
    cam.End3D()
    render.SuppressEngineLighting(false)

    cam.Start2D()
        local p = vgui.GetKeyboardFocus()

        local function GetLast(pnl)
            local parent = pnl:GetParent()
            pnl:PaintManual()
            if IsValid(parent) then
                return GetLast(parent)
            end
            return pnl
        end

        if IsValid(p) then
            local last = GetLast(p)
            
            last:PaintManual()
        end
    cam.End2D()

    for k, v in ipairs(player.GetAll()) do
        if v.oModel then
            if v == LocalPlayer() then
                v:SetModelScale(1.5)
            end
            v:SetModel(v.oModel)
        end
    end
end)

hook.Add("PreRender", "", function()
    render.ClearRenderTarget(rt, color_black)
    render.SetRenderTarget(nil)
end)
