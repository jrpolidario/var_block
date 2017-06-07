# VarArray objects are only created when using `merge` or `merge_with`. Do not initialise them manually.
module VarBlock
	class VarArray < Array
	end
end