package main

import "testing"

func TestMinElement(t *testing.T) {
	var min int
	var err error

	min, err = minElement([]int{})
	if err == nil {
		t.Fatalf(`minElement([]int{}) = %d, %v, wants _, error`, min, err)
	}

	min, err = minElement([]int{1, 2, 3})
	if min != 1 || err != nil {
		t.Fatalf(`minElement([]int{1, 2, 3}) = %d, %v, wants 1, nil`, min, err)
	}

	min, err = minElement([]int{2, 1, 3})
	if min != 1 || err != nil {
		t.Fatalf(`minElement([]int{2, 1, 3}) = %d, %v, wants 1, nil`, min, err)
	}

	min, err = minElement([]int{2, 3, 1})
	if min != 1 || err != nil {
		t.Fatalf(`minElement([]int{2, 3, 1}) = %d, %v, wants 1, nil`, min, err)
	}
}
