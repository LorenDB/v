import sync

const (
	iterations_per_thread2 = 100000
)

fn inc_elements(shared foo []int, n int, sem sync.Semaphore) {
	for _ in 0 .. iterations_per_thread2 {
		foo[n]++
	}
	sem.post() // indicat that thread is finished
}

fn test_autolocked_array_2() {
	shared abc := &[0, 0, 0]
	sem := sync.new_semaphore()
	go inc_elements(shared abc, 1, sem)
	go inc_elements(shared abc, 2, sem)
	for _ in 0 .. iterations_per_thread2 {
		abc[2]++
	}
	// wait for the 2 coroutines to finish using the semaphore
	for _ in 0 .. 2 {
		sem.wait()
	}
	rlock abc {
		assert abc[1] == iterations_per_thread2
		assert abc[2] == 2 * iterations_per_thread2
	}
}
