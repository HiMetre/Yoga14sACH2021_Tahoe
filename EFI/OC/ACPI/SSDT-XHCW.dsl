/*
 * Dock on GP17.XHC0 / GP17.XHC1 dark-wakes S3 after a full wake.
 * GPRW sleep-level 0 silenced the bridge only. AppleUSBXHCIPCI
 * rearms PME on the controllers. acpi-pmcap-offset is 80, so
 * PMCSR is at config offset 0x54. Bit 8 is PME Enable, bit 15
 * is PME Status (write 1 to clear).
 *
 * OpenCore, DSDT:
 *   _PTS -> ZPTS   Find 5F 50 54 53 01  Replace 5A 50 54 53 01  Count 1
 *   _PRW -> XPRW   body Return (GPRW (0x19, 0x03)) and the 0x04 form
 *   _PRW -> XPRW   GP17 If (WKPM) returning GPRW (0x19, 0x03 or 0x04)
 * Lid and the power button do not use GPE 0x19.
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "XHCW", 0x00000000)
{
    External (ZPTS, MethodObj)
    External (\_SB.PCI0.GP17, DeviceObj)
    External (\_SB.PCI0.GP17.XHC0, DeviceObj)
    External (\_SB.PCI0.GP17.XHC1, DeviceObj)

    Scope (\_SB.PCI0.GP17)
    {
        OperationRegion (GPMR, PCI_Config, 0x54, 0x02)
        Field (GPMR, WordAcc, NoLock, Preserve)
        {
            ,   8,
            GPEE,   1,
            ,   6,
            GPES,   1
        }
    }

    Scope (\_SB.PCI0.GP17.XHC0)
    {
        OperationRegion (X0PR, PCI_Config, 0x54, 0x02)
        Field (X0PR, WordAcc, NoLock, Preserve)
        {
            ,   8,
            X0EE,   1,
            ,   6,
            X0ES,   1
        }
    }

    Scope (\_SB.PCI0.GP17.XHC1)
    {
        OperationRegion (X1PR, PCI_Config, 0x54, 0x02)
        Field (X1PR, WordAcc, NoLock, Preserve)
        {
            ,   8,
            X1EE,   1,
            ,   6,
            X1ES,   1
        }
    }

    Method (XPME, 0, NotSerialized)
    {
        \_SB.PCI0.GP17.GPEE = Zero
        \_SB.PCI0.GP17.GPES = One
        \_SB.PCI0.GP17.XHC0.X0EE = Zero
        \_SB.PCI0.GP17.XHC0.X0ES = One
        \_SB.PCI0.GP17.XHC1.X1EE = Zero
        \_SB.PCI0.GP17.XHC1.X1ES = One
    }

    Method (_PTS, 1, NotSerialized)
    {
        ZPTS (Arg0)
        XPME ()
    }
}
