# Minetest-Mod: adminshop
Github: https://github.com/Jean28518/minetest_adminshop

Mod for Minetest, which adds adminshops.

There are no crafting recipe available.
To place and to break adminshops you need the "adminshop" privilege assigned. Only the owner (placer) of the adminshop is able to change the offer.

## Optional: How to work with licenses and adminshop
The Mod can be found at: https://github.com/Jean28518/minetest_licenses

When the Mod activated you can find a new Item called "Adminshop with licenses integrated".
When the licenses list in the shop window is empty, everyone can buy something
from the shop.

You can add a license, by typing the license in the textfield, and clicking to
"Add". Please remind that this license has to be defined before by `/licenses_add LICENSE`.

You remove a license from the list by typing the name in the textfield and clicking "Remove"

When there are some licenses in the license list in the shop window, then **only
players can buy**, whose are **having at least one license assigned, which was
defined in the shop window** by the owner. Only the owner of the shop is able
to define the required licenses.

## Optional: adminshop with currency and atm
For that feature you have to installed "licenses" too. This Feature adds an third adminshop, wich takes access to the atm balance of a player.

ATM: https://forum.minetest.net/viewtopic.php?t=15029&p=223265

Currency: https://github.com/minetest-mods/currency
