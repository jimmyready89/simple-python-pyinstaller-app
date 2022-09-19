FROM alpine:3.16.2

COPY ./desc .

RUN chmod a+x add2vals

CMD ["./add2vals", "1", "2"]