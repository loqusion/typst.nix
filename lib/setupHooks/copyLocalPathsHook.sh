copyLocalPaths() {
	@copyAllLocalPaths@
}

preBuildHooks+=(copyLocalPaths)
