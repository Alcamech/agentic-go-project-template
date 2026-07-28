// Package greeter provides simple greeting helpers.
package greeter

import "strings"

// Hello returns a greeting for name, defaulting to "world" when empty.
func Hello(name string) string {
	name = strings.TrimSpace(name)
	if name == "" {
		name = "world"
	}
	return "Hello, " + name + "!"
}
