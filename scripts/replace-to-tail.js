#!/usr/local/bin/zx
// $.verbose = false

async function getDeployment(ns, deployment) {
	const deploymentJsonStr = (await $`kubectl get deployment -n ${ns} ${deployment} -o json`).stdout
	return JSON.parse(deploymentJsonStr)
}

function generateAnnotation(deployment) {
	const ret = {}
	const containers = deployment.spec.template.spec.containers
	console.log(containers.length);
	for (const index in containers) {
		const container = containers[index]
		ret[container.name] = {
			name: container.name,
			index: index,
			command: container.command,
			args: container.args,
		}
		console.log(container);
		console.log(index);
	}
	return ret;
}


async function setTailAnnotation(ns, deployment, annotation) {
	console.log(JSON.stringify(annotation));
	const cmd = `kubectl annotate --overwrite deployments.apps ${deployment} -n ${ns} wg.k8s.tools.tail/tail='${JSON.stringify(annotation).replaceAll('"', '!')}'`
	console.log(cmd);
	// const output = (await $`kubectl annotate --overwrite deployments.apps ${deployment} -n ${ns} wg.k8s.tools.tail/tail='${JSON.stringify(annotation)}'`).stdout
	// const output = (await $`kubectl annotate --overwrite deployments.apps ${deployment} -n ${ns} wg.k8s.tools.tail/tail='${JSON.stringify(annotation)}'`).stdout
	console.log(JSON.stringify(annotation));
	const output = (await $`kubectl annotate --overwrite deployments.apps ${deployment} -n ${ns} wg.k8s.tools.tail/tail='`+JSON.stringify(annotation)+"'").stdout
	console.log(output);
}

async function removeTailAnnotation(ns, deployment) {

}

async function hasTailAnnotation(ns, deployment) {

}

async function getTailAnnotation(ns, deployment) {

}


async function main() {
	const ns = "cpaas-system"
	const depName = "alb-dev"
	const deployment = await getDeployment(ns, depName)
	const annotations = generateAnnotation(deployment)
	await setTailAnnotation(ns, depName, annotations)
	console.log(annotations);
}
main()