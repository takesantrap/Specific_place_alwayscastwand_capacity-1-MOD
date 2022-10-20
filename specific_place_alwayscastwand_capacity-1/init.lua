dofile_once ("data/scripts/lib/utilities.lua")
dofile_once("mods/noita-together/files/scripts/utils.lua")
dofile_once("mods/noita-together/files/store.lua")
dofile_once("mods/noita-together/files/scripts/json.lua")

function get_player()
    local players = get_players()
    if players then
        return players[1]
    end
    return nil
end

local player

local flag

local count = 0

function OnPlayerSpawned()
    player = get_player()
    flag = GameHasFlagRun("run_nightmare")
end

function OnWorldPreUpdate()
    local pos_x, pos_y = EntityGetTransform(player)

    local distances

    if (flag) then
        distances = {
            math.abs(pos_x - (-515)) + math.abs(pos_y - 1380),
            math.abs(pos_x - (-515)) + math.abs(pos_y - 3940),
            math.abs(pos_x - (-515)) + math.abs(pos_y - 6500),
            math.abs(pos_x - (-515)) + math.abs(pos_y - 8550),
            math.abs(pos_x - (-515)) + math.abs(pos_y - 10600),
            math.abs(pos_x - 2075) + math.abs(pos_y - 13155)
        }
    else
        distances = {
            math.abs(pos_x - (-515)) + math.abs(pos_y - 1380),
            math.abs(pos_x - (-515)) + math.abs(pos_y - 2920),
            math.abs(pos_x - (-515)) + math.abs(pos_y - 4965),
            math.abs(pos_x - (-515)) + math.abs(pos_y - 6500),
            math.abs(pos_x - (-515)) + math.abs(pos_y - 8550),
            math.abs(pos_x - (-515)) + math.abs(pos_y - 10600),
            math.abs(pos_x - 2075) + math.abs(pos_y - 13155)
        }
    end

    --周辺の杖を配列で取得
    local wands = EntityGetInRadiusWithTag(pos_x, pos_y, 15, "wand")

    for _, wand in ipairs(wands) do
        local childs = EntityGetAllChildren(wand)
        for _, child in ipairs(childs) do
            local item_comp = EntityGetFirstComponentIncludingDisabled(child, "ItemComponent")
            local is_always_cast = ComponentGetValue2(item_comp, "permanently_attached")
            --条件、その杖に常時詠唱が付いている
            if (is_always_cast) then
                local tags = EntityGetTags(wand)
                --条件、その杖を初めて確認する時
                if (string.find(tags,"capacitycheck")) == nil then
                    for _, distance in ipairs(distances) do
                        --特定の場所の近くにいる時
                        if (distance < 25) then
                            local ability_comp = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
                            local deck_capacity = ComponentObjectGetValue2(ability_comp, "gun_config", "deck_capacity")
                            ComponentObjectSetValue2(ability_comp, "gun_config", "deck_capacity", deck_capacity - 1)
                        end
                    end
                    EntityAddTag(wand, "capacitycheck")
                end
            end
        end
    end

    if (#wands > 1) then
        local distance = math.abs(pos_x - 3547) + math.abs(pos_y - 13110)
        if (distance < 30) then
            count = count + 1
            if (count > 3000) then
                if (not NT.sampo_pickup) then
                    NT.sampo_pickup = true
                    NT.players_sampo = NT.players_sampo + 1
                    local queue = json.decode(NT.wsQueue)
                    table.insert(queue, {event="CustomModEvent", payload={name="SampoPickup"}})
                    NT.wsQueue = json.encode(queue)
                end
            end
        end
    end
end