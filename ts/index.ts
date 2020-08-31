const circom = require('circom')
const libsemaphore = require('libsemaphore')

const main = async () => {
    const leaves = [1, 2, 3, 4].map(BigInt)
    const tree = await libsemaphore.genTree(2, leaves)
    const index = 2
    const leaf = leaves[index]
    const path = await tree.path(index)

    const circuit = await circom.tester('./circuit_works.circom')

    const circuitInputs = {
        leaf,
        path_elements: path.path_elements,
        path_index: path.path_index,
    }

    const witness = await circuit.calculateWitness(circuitInputs)
    await circuit.checkConstraints(witness)
    await circuit.loadSymbols()
    console.log('circuit_works.json is OK')

    try {
        const circuit2 = await circom.tester('./circuit_bad.circom')
        const witness = await circuit2.calculateWitness(circuitInputs)
        await circuit2.checkConstraints(witness)
    } catch (e) {
        console.log('circuit_bad.json is not OK')
        console.log(e)
    }
}

main()
