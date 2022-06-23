-- Extension module for the mugen module.
-- Unlike player.lua, this just extends the existing functionality of the mugen module, rather than wrapping it.
-- This is because mugen module doesn't expose userdata objects, so it's easy to add new methods which are immediately available.

-- BEGIN MUGEN MODULE NEW FUNCTIONALITY
function mugen.getbaseaddress()
	return mll.ReadInteger(0x5040E8)
end
-- END MUGEN MODULE NEW FUNCTIONALITY