#!/usr/local/bin/zx
// $.verbose = false
const CWD = (await $`echo $PWD`).stdout.trim()

const GOPKG = {
	"controller-runtime": `${os.homedir()}/sm/lab/controller-runtime`
}

console.log(GOPKG)

// {pkg:string,hash:string,tag:string}
// /xx/pkg/mod/sigs.k8s.io/controller-runtime@v0.3.1-0.20191011155846-b2bc3490f2e5
// -> controller-runtime b2bc3490f2e5 v0.3.1-0
async function parse_name(name) {
	const pkg = (await $`echo ${name} | rg -o '.*/([^@]*)@' -r '$1'`).stdout.trim()
	const tag_hash = (await $`echo ${name} | rg -o '.*@(.*)' -r '$1'`).stdout.trim().split('-')
	const tag = tag_hash[0]
	const hash = tag_hash.slice(-1)[0]
	return { pkg: pkg, hash, tag }
}

async function is_git_clean(dir) {
	const output = await $`cd ${dir} && git status`
	return output.stdout.includes('working tree clean')
}

async function get_git_current_commit(dir) {
	return (await $`cd ${dir} && git log --pretty=format:'%h' -n 1`).stdout.trim()
}

async function get_git_current_tag(dir) {
	return (await $`cd ${dir} &&  git describe --exact-match --tags $(git log -n1 --pretty='%h')`).stdout.trim()
}

async function ami_this_commit(dir, pkg) {
	if (pkg.hash) {
		const commit = await get_git_current_commit(dir)
		return commit == pkg.hash
	} else {
		const tag = await get_git_current_tag(dir)
		return tag == pkg.tag
	}
}

async function git_set_to(dir, pkg) {
	// i dont care is this pkg valid or not
	if (pkg.hash) {
		await $`cd ${dir} && git checkout ${pkg.hash}`
	} else {
		await $`cd ${dir} && git checkout ${pkg.tag}`
	}
	if (!ami_this_commit(dir, pkg)) {
		throw new Error("sth happen set to this commit but fail", pkg)
	}
}

async function make_sure_source_pkg_version(source_pkg_dir, pkg) {
	// is this commit is expected commit?
	if (await ami_this_commit(source_pkg_dir, pkg) && await is_git_clean(source_pkg_dir)) {
		// ok
		return
	}

	if (!await is_git_clean(source_pkg_dir)) {
		throw new Error(`this dit ${source_pkg_dir} is not clean now`)
	}

	if (!await ami_this_commit(source_pkg_dir, pkg)) {
		await git_set_to(source_pkg_dir, pkg)
	}
}

// return: []string
async function find_diff(left, right) {
	let out = {}
	try {
		out = await $`git diff --name-only --no-index ${left} ${right} | grep -v '.git'`
	} catch (e) {
		if (e.stderr != "") {
			console.log("xxxerr");
			throw new Error(e)
		}
		console.log("no err");
		out = e
	}
	return out.stdout.split('\n')
}


async function main() {
	const pkg = await parse_name(CWD)
	console.log(pkg);
	const source_pkg = GOPKG[pkg.pkg]

	if (!source_pkg) {
		console.log("could not find this pkg ", pkg)
		os.exit(0)
	}

	await make_sure_source_pkg_version(source_pkg, pkg)
	// start diff
	const diff_list = await find_diff(CWD, source_pkg)
	console.log(diff_list);
}

try {
	await main()
} catch (e) {
	console.log("sth wrong", e);
}