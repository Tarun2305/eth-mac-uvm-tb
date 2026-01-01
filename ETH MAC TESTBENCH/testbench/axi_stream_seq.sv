class simple_sequence extends uvm_sequence #(axi_stream_pkt);
  rand int unsigned n_pkts = 3;

  `uvm_object_utils(simple_sequence)

  function new(string name="simple_sequence");
    super.new(name);
  endfunction

  task body();
    axi_stream_pkt req;
    for (int k=0; k<n_pkts; k++) begin
      req = axi_stream_pkt::type_id::create($sformatf("req_%0d", k));
      if (!req.randomize()) `uvm_fatal("RAND","Failed to randomize packet");
      start_item(req);
      finish_item(req);
    end
  endtask
endclass
