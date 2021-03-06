/*
*  Copyright 2021 Michail Vourlakos <mvourlakos@gmail.com>
*
*  This file is part of Latte-Dock
*
*  Latte-Dock is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License as
*  published by the Free Software Foundation; either version 2 of
*  the License, or (at your option) any later version.
*
*  Latte-Dock is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.7

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.latte.core 0.2 as LatteCore

Item {
    Binding {
        target: _abilityContainer.layout
        property: "columns"
        value: plasmoid.formFactor === PlasmaCore.Types.Vertical ? 1 : 0
    }

    Binding {
        target: _abilityContainer.layout
        property: "rows"
        value: plasmoid.formFactor === PlasmaCore.Types.Vertical ? 0 : 1
    }

    Binding {
        target: _abilityContainer.layout
        property: "columnSpacing"
        value: 0
    }

    Binding {
        target: _abilityContainer.layout
        property: "rowSpacing"
        value: 0
    }

    Binding {
        target: _abilityContainer.layout
        property: "flow"
        value: plasmoid.formFactor === PlasmaCore.Types.Vertical ? Grid.TopToBottom : Grid.LeftToRight
    }

    states: [
        ///Left Edge
        State {
            name: "leftCenter"
            when: (_abilityContainer.location===PlasmaCore.Types.LeftEdge && _abilityContainer.alignment===LatteCore.Types.Center)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignLeft; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        State {
            name: "leftTop"
            when: (_abilityContainer.location===PlasmaCore.Types.LeftEdge && _abilityContainer.alignment===LatteCore.Types.Top)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignLeft; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        State {
            name: "leftBottom"
            when: (_abilityContainer.location===PlasmaCore.Types.LeftEdge && _abilityContainer.alignment===LatteCore.Types.Bottom)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignLeft; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        ///Right Edge
        State {
            name: "rightCenter"
            when: (_abilityContainer.location===PlasmaCore.Types.RightEdge && _abilityContainer.alignment===LatteCore.Types.Center)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignRight; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        State {
            name: "rightTop"
            when: (_abilityContainer.location===PlasmaCore.Types.RightEdge && _abilityContainer.alignment===LatteCore.Types.Top)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignRight; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        State {
            name: "rightBottom"
            when: (_abilityContainer.location===PlasmaCore.Types.RightEdge && _abilityContainer.alignment===LatteCore.Types.Bottom)

            PropertyChanges{
                target: _abilityContainer.layout; horizontalItemAlignment: Grid.AlignRight; verticalItemAlignment: Grid.AlignVCenter;
            }
        },
        ///Bottom Edge
        State {
            name: "bottomCenter"
            when: (_abilityContainer.location===PlasmaCore.Types.BottomEdge && _abilityContainer.alignment===LatteCore.Types.Center)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignBottom
            }
        },
        State {
            name: "bottomLeft"
            when: (_abilityContainer.location===PlasmaCore.Types.BottomEdge && _abilityContainer.alignment===LatteCore.Types.Left)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignBottom
            }
        },
        State {
            name: "bottomRight"
            when: (_abilityContainer.location===PlasmaCore.Types.BottomEdge && _abilityContainer.alignment===LatteCore.Types.Right)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignBottom
            }
        },
        ///Top Edge
        State {
            name: "topCenter"
            when: (_abilityContainer.location===PlasmaCore.Types.TopEdge && _abilityContainer.alignment===LatteCore.Types.Center)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignTop
            }
        },
        State {
            name: "topLeft"
            when: (_abilityContainer.location===PlasmaCore.Types.TopEdge && _abilityContainer.alignment===LatteCore.Types.Left)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignTop
            }
        },
        State {
            name: "topRight"
            when: (_abilityContainer.location===PlasmaCore.Types.TopEdge && _abilityContainer.alignment===LatteCore.Types.Right)

            PropertyChanges{
                target: _abilityContainer.layout;
                horizontalItemAlignment: Grid.AlignHCenter; verticalItemAlignment: Grid.AlignTop
            }
        }
    ]
    ////////////////END states
}
