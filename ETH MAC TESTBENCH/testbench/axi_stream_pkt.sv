class axi_stream_pkt extends uvm_sequence_item;
  // use a queue (supports push_back, size, etc.)
  rand byte unsigned data[$];
  rand int unsigned  length;

  constraint c_len { length inside {[60:100]}; }

  `uvm_object_utils(axi_stream_pkt)
  function new(string name="axi_stream_pkt"); super.new(name); endfunction

  function void post_randomize();
    data.delete();
    for (int i=0; i<length; i++) data.push_back($urandom_range(0,255));
  endfunction
endclass
