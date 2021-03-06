/*
 * Author: commy2
 * Get the turret index of a vehicles commander.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Vehicle commander turrent indecies <ARRAY>
 *
 * Public: Yes
 */
#include "script_component.hpp"

params [["_vehicle", objNull, [objNull]]];

private _turrets = allTurrets [_vehicle, true];

private _turret = [];

{
    private _config = configFile >> "CfgVehicles" >> typeOf _vehicle;

    _config = [_config, _x] call FUNC(getTurretConfigPath);

    if (getNumber (_config >> "primaryObserver") == 1) exitWith {
        _turret = _x;
    };
    false
} count _turrets;

_turret
