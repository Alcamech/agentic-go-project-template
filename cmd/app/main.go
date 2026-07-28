// Command app is a tiny greeter sample.
package main

import (
	"fmt"
	"os"

	"github.com/OWNER/REPO/internal/greeter"
)

func main() {
	name := "world"
	if len(os.Args) > 1 {
		name = os.Args[1]
	}
	fmt.Println(greeter.Hello(name))
}
