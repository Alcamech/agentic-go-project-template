package greeter_test

import (
	"testing"

	"github.com/OWNER/REPO/internal/greeter"
)

func TestHello(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name string
		in   string
		want string
	}{
		{name: "typical", in: "Ada", want: "Hello, Ada!"},
		{name: "empty falls back", in: "", want: "Hello, world!"},
		{name: "whitespace falls back", in: "  ", want: "Hello, world!"},
		{name: "trims spaces", in: "  Grace  ", want: "Hello, Grace!"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			got := greeter.Hello(tt.in)
			if got != tt.want {
				t.Fatalf("Hello(%q) = %q, want %q", tt.in, got, tt.want)
			}
		})
	}
}
