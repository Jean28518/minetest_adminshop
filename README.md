# Minetest-Mod: adminshop
Github: https://github.com/Jean28518/minetest_adminshop

Mod for Minetest, which adds adminshops.

There is no crafting recipe available.
To place and to break adminshops you need the "adminshop" privilege assigned.

## How to work with licenses and adminshop
The Mod can be found at: https://github.com/Jean28518/minetest_licenses

When the Mod activated you can find a new Item called "Adminshop with licenses integrated".
When the licenses list in the shop window is empty, everyone can buy something
from the shop.

You can add a license, by typing the license in the textfield, and clicking to
"Add". Please remind that this license has to be defined before by `licenses_add LICENSE`.

When there are some licenses in the license list in the shop window, then **only
players can buy**, whose are **having at least one license assigned, which was
defined in the shop window** by the owner. Only the owner of the shop is able
to define the required licenses.
