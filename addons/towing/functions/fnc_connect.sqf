/*
 * Author: GitHawk
 * Connects a tilting rope to a vehicle.
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [tank, player] call ace_towing_fnc_connect
 *
 * Public: no
 */
#include "script_component.hpp"

#define PLACE_WAITING -1
#define PLACE_CANCEL 0
#define PLACE_APPROVE 1

params ["_target", "_unit"];

GVAR(placeAction) = PLACE_WAITING;

[_unit, QGVAR(vehAttach), true] call EFUNC(common,setForceWalkStatus);

[{[localize LSTRING(TiltingActionShort), ""] call EFUNC(interaction,showMouseHint)}, []] call EFUNC(common,execNextFrame);
_unit setVariable [QGVAR(placeActionEH), [_unit, "DefaultAction", {true}, {GVAR(placeAction) = PLACE_APPROVE;}] call EFUNC(common,addActionEventHandler)];

_actionID = _unit addAction [format ["<t color='#FF0000'>%1</t>", localize LSTRING(Cancel)], {GVAR(placeAction) = PLACE_CANCEL; [_unit, QGVAR(vehAttach), false] call EFUNC(common,setForceWalkStatus);}];

[{
    private["_virtualPos", "_virtualPosASL", "_lineInterection"];

    params ["_args","_pfID"];
    EXPLODE_3_PVT(_args,_unit,_attachToVehicle,_actionID);

    _virtualPosASL = (eyePos _unit) vectorAdd (positionCameraToWorld [0,0,0.6]) vectorDiff (positionCameraToWorld [0,0,0]);
    if (cameraView == "EXTERNAL") then {
        _virtualPosASL = _virtualPosASL vectorAdd ((positionCameraToWorld [0.3,0,0]) vectorDiff (positionCameraToWorld [0,0,0]));
    };
    _virtualPos = _virtualPosASL call EFUNC(common,ASLToPosition);
    _lineInterection = lineIntersects [eyePos ace_player, _virtualPosASL, ace_player];

    //Don't allow placing in a bad position:
    if (_lineInterection && {GVAR(placeAction) == PLACE_APPROVE}) then {GVAR(placeAction) = PLACE_WAITING;};

    if ((GVAR(placeAction) != PLACE_WAITING) ||
            {_unit != ace_player} ||
            {!([_unit, _attachToVehicle, []] call EFUNC(common,canInteractWith))}) then {

        [_pfID] call CBA_fnc_removePerFrameHandler;
        [] call EFUNC(interaction,hideMouseHint);
        [_unit, "DefaultAction", (_unit getVariable [QGVAR(placeActionEH), -1])] call EFUNC(common,removeActionEventHandler);
        _unit removeAction _actionID;

        if (GVAR(placeAction) == PLACE_APPROVE) then {
            [_unit, _attachToVehicle, _virtualPos] call FUNC(tiltConnect);
        };
    }; // TODO add model like in attach/functions/fnc_attach
}, 0, [_unit, _target, _actionID] ] call cba_fnc_addPerFrameHandler;
