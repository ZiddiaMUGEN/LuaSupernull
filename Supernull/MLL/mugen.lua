-- Extension module for the mugen module.
-- Unlike player.lua, this just extends the existing functionality of the mugen module, rather than wrapping it.
-- This is because mugen module doesn't expose userdata objects, so it's easy to add new methods which are immediately available.

-- BEGIN MUGEN MODULE NEW FUNCTIONALITY
function mugen.getbaseaddress()
	return mll.ReadInteger(0x5040E8)
end

function mugen.gametimeset(value) mll.WriteInteger(mugen.getbaseaddress() + 0x11E98, value) end
function mugen.roundnoset(value) mll.WriteInteger(mugen.getbaseaddress() + 0x12728, value) end
function mugen.roundstateset(value) mll.WriteInteger(mugen.getbaseaddress() + 0x12754, value) end
function mugen.matchnoset(value) mll.WriteInteger(mugen.getbaseaddress() + 0x12824, value) end

function mugen.isassertintro() return mll.ReadByte(mugen.getbaseaddress() + 0x1269C) end
function mugen.isassertroundnotover() return mll.ReadByte(mugen.getbaseaddress() + 0x1269D) end
function mugen.isassertnoko() return mll.ReadByte(mugen.getbaseaddress() + 0x1269E) end
function mugen.isassertnokosnd() return mll.ReadByte(mugen.getbaseaddress() + 0x1269F) end
function mugen.isassertnokoslow() return mll.ReadByte(mugen.getbaseaddress() + 0x126A0) end
function mugen.isassertnomusic() return mll.ReadByte(mugen.getbaseaddress() + 0x126A1) end
function mugen.isassertglobalnoshadow() return mll.ReadByte(mugen.getbaseaddress() + 0x126A2) end
function mugen.isasserttimerfreeze() return mll.ReadByte(mugen.getbaseaddress() + 0x126A3) end
function mugen.isassertnobardisplay() return mll.ReadByte(mugen.getbaseaddress() + 0x126A4) end
function mugen.isassertnobg() return mll.ReadByte(mugen.getbaseaddress() + 0x126A5) end
function mugen.isassertnofg() return mll.ReadByte(mugen.getbaseaddress() + 0x126A6) end
-- END MUGEN MODULE NEW FUNCTIONALITY