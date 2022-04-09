		function lua-echo() { 
			lua <<-EOF
				require ("zmx").on_call("actions.test_sh","lua-echo","$@")
			EOF
		}
			function lua-len() { 
			lua <<-EOF
				require ("zmx").on_call("actions.test_sh","lua-len","$@")
			EOF
		}
	