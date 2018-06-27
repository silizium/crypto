function unrequire(m)
	package.loaded[m] = nil
	_G[m] = nil
end