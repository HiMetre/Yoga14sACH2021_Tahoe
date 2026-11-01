/*
 * GP17, XHC0 and XHC1 wake on GPE 0x19. The dock on those controllers
 * dark-wakes a closed lid; that wake can stall in VoodooI2CHIDDevice.
 * LID does not use this GPE.
 *
 * OpenCore renames firmware Method (GPRW, 2) to XPRW.
 * Find 47 50 52 57 02, Replace 58 50 52 57 02, TableSignature DSDT.
 */
DefinitionBlock ("", "SSDT", 2, "HACK", "GPRW", 0x00000000)
{
    External (XPRW, MethodObj)    // 2 Arguments

    Method (GPRW, 2, NotSerialized)
    {
        If ((Arg0 == 0x19))
        {
            Return (Package (0x02)
            {
                0x19, 
                Zero
            })
        }

        Return (XPRW (Arg0, Arg1))
    }
}

