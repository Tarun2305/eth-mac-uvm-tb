class axi_stream_monitor extends uvm_monitor;
    virtual axi_stream_if vif;
    uvm_analysis_port #(axi_stream_pkt) ap;

    `uvm_component_utils(axi_stream_monitor)

    function new(string name="axi_stream_monitor", uvm_component parent=null);
        super.new(name,parent);
        ap = new("ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual axi_stream_if)::get(this, "", "vif", vif))
           `uvm_fatal("NOVIF","No virtual interface for monitor");
    endfunction

    task run_phase(uvm_phase phase);
        axi_stream_pkt tr;
        tr = axi_stream_pkt::type_id::create("tr");

        tr.data.delete();

        forever begin
            @(posedge vif.clk);
            if(vif.tvalid && vif.tready) begin
                tr.data.push_back(vif.tdata);

                if(vif.tlast) begin
                    ap.write(tr);
                    tr = axi_stream_pkt::type_id::create("tr");
                    tr.data.delete();
                end
            end
        end
    endtask
endclass
